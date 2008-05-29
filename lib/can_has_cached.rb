$:.unshift File.dirname(__FILE__)

require 'rubygems'
require 'memcached'
require 'set'

module CanHasCached
  # Stolen from ActiveSupport to support Hash#slice
  unless Hash.method_defined?(:slice) && Hash.method_defined?(:slice!)
    Hash.class_eval do
      # Returns a new hash with only the given keys.
      def slice(*keys)
        allowed = Set.new(respond_to?(:convert_key) ? keys.map { |key| convert_key(key) } : keys)
        reject { |key,| !allowed.include?(key) }
      end

      # Modifies hash in place to have only the given keys.
      def slice!(*keys)
        replace(slice(*keys))
      end
    end
  end

  def self.included(base)
    base.extend(ClassMethods)
    base.send(:include, InstanceMethods)
  end

  module ClassMethods
    @ttl = nil
    @cache_config = nil

    def cache
      raise ArgumentError, "cache_config must be set before you can use CanHasCached" if cache_config.nil?
      @cache ||= Memcached.new(cache_config[:servers], cache_config.slice(*allowed_options))
    end

    def cache_config
      @cache_config
    end

    def cache_config=(config)
      raise ArgumentError, "cache_config for CanHasCached must be a Hash" unless config.is_a?(Hash)
      # Set the config now
      @cache_config = config
    end

    def ttl
      @ttl
    end

    def ttl=(new_ttl)
      raise ArgumentError, "ttl for CanHasCached must be a Fixnum" unless new_ttl.is_a?(Fixnum)
      @ttl = new_ttl
    end

    # Returns the cache key to use for a given ID. This generally includes the class name and cache version, if any.
    def cache_key(cache_id)
      version = cache_config[:version] unless cache_config.nil?
      [self.name, version, cache_id].compact.join(':').gsub(' ', '_')
    end

    # Sets value into cache, with the given optional TTL (in seconds). If <code>ttl</code> is not given, it's taken from
    # the @ttl class variable, failing which, from cache_config[:ttl].
    def set_cache(cache_id, value, ttl = nil)
      cache.set(cache_key(cache_id), value, ttl || self.ttl || cache_config[:ttl] || 0)
      value
    end

    # Gets cached value from cache, auto-magically loading any missing constants if needed for unmarshalling.
    # Accepts an optional block, whose return value will be cached if the key does not already exist.
    #
    # == Examples
    #   # Returns the cached value with ID of 'foo' if it exists in the cache.
    #   get_cache('foo')
    #
    #   # Calls some_expensive_method if the cached value with ID of 'foo' if it doesn't already exist in the cache.
    #   get_cache('foo') { some_expensive_method }
    #
    # Warning: this method rescues from Memcached::NotFound and returns nil if the key does not exist!
    def get_cache(cache_id)
      begin
        autoload_missing_constants do
          cache.get(cache_key(cache_id))
        end
      rescue Memcached::NotFound
        block_given? ? set_cache(cache_id, yield) : nil
      end
    end

    private
      # Stolen from cache_fu's implementation.
      def autoload_missing_constants
        yield
      rescue ArgumentError => error
        lazy_load ||= Hash.new { |hash, hash_key| hash[hash_key] = true; false }
        if error.to_s[/undefined class|referred/] && !lazy_load[error.to_s.split.last.constantize] then retry
        else raise error end
      end
      
      def allowed_options
        [:namespace, :hash, :distribution, :support_cas, :tcp_nodelay, :no_block, :buffer_request, :show_not_found_backtraces]
      end
  end

  module InstanceMethods
    def cache_config
      self.class.cache_config
    end

    def set_cache(cache_id, value = self, ttl = nil)
      self.class.set_cache(cache_id, value, ttl)
    end

    def get_cache(cache_id, &block)
      self.class.get_cache(cache_id, &block)
    end

    def cache
      self.class.cache
    end

  end
end