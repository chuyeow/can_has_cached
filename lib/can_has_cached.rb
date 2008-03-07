$:.unshift File.dirname(__FILE__)

require 'memcached'

# TODO Write some specs you pussy.
# TODO Remove dependency on RAILS_ROOT and RAILS_ENV.
module CanHasCached

  def self.included(base)
    base.extend(ClassMethods)
    base.send(:include, InstanceMethods)
  end

  module ClassMethods
    @@ttl = nil

    def allowed_options
      [:namespace, :hash, :distribution, :support_cas, :tcp_nodelay, :no_block, :buffer_request, :show_not_found_backtraces]
    end

    def cache_config
      @@cache_config ||= YAML.load(ERB.new(IO.read(File.join(RAILS_ROOT, 'config', 'memcached.yml'))).result)[RAILS_ENV]
    end

    def cache
      @@cache ||= Memcached.new(cache_config[:servers], cache_config.slice(*allowed_options))
    end

    def ttl
      @@ttl
    end

    def ttl=(new_ttl)
      @@ttl = new_ttl
    end

    # Returns the cache key to use for a given ID. This generally includes the class name and cache version, if any.
    def cache_key(cache_id)
      [self.name, cache_config[:version], cache_id].compact.join(':').gsub(' ', '_')
    end

    # Sets value into cache, with the given optional TTL (in seconds). If <code>ttl</code> is not given, it's taken from
    # the @@ttl class variable, failing which, from cache_config[:ttl].
    def set_cache(cache_id, value, ttl = nil)
      cache.set(cache_key(cache_id), value, ttl || self.ttl || cache_config[:ttl] || 0)
    end

    # Gets cached value from cache, auto-magically loading any missing constants if needed for unmarshalling.
    # Warning: this method rescues from Memcached::NotFound and returns nil if the key does not exist!
    def get_cache(cache_id)
      begin
        autoload_missing_constants do
          cache.get(cache_key(cache_id))
        end
      rescue Memcached::NotFound
        nil
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
  end

  module InstanceMethods
    def cache_config
      self.class.cache_config
    end

    def cache
      self.class.cache
    end

    def set_cache(cache_id, value = self, ttl = nil)
      self.class.set_cache(cache_id, value, ttl)
    end

    def get_cache(cache_id)
      self.class.get_cache(cache_id(key), options, &block)
    end
  end
end