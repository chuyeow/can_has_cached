require File.dirname(__FILE__) + '/../spec_helper.rb'

describe CanHasCached do
  before(:each) do
    class Person
      include CanHasCached

      def expensive_computation
        42
      end
    end

    @mock_cache = mock(Memcached)
    @person = Person.new

    Person.stub!(:cache).and_return(@mock_cache)
    Person.cache_config = {:servers => "localhost:11211"}
  end

  after(:each) do
    Object.send(:remove_const, :Person)
  end

  describe "#get_cache with a block" do
    it "should return the value of the block if the cache ID given does not exist in memcached" do
      Person.should_receive(:cache_key).with('my_id').and_return('Person::my_id')
      @mock_cache.should_receive(:get).with('Person::my_id').and_raise(Memcached::NotFound)
      Person.should_receive(:set_cache).with('my_id', 42).and_return(42)

      @person.get_cache('my_id') { @person.expensive_computation }.should == 42
    end
  end
end

describe "CanHasCached #get_cache method, with @cache_config not set" do
  before(:each) do
    class Person
      include CanHasCached
    end
  end
  
  after(:each) do
    Object.send(:remove_const, :Person)
  end
  
  it "should raise an error if cache_config is not set while calling the get_cache class method" do
    lambda { Person.get_cache("123") }.should raise_error(ArgumentError, "cache_config must be set before you can use CanHasCached")
  end
end

describe "CanHasCached #get_cache method, with @cache_config set and Memcached#get returns an actual object from cache" do
  before(:each) do
    class Person
      include CanHasCached
      attr_accessor :name

      def initialize(options = {})
        self.name = options[:name]
      end
    end

    @mock_cache = mock('Memcached')
    @cached_person = Person.new(:name => 'McLovin')

    Person.stub!(:cache).and_return(@mock_cache)
    @mock_cache.stub!(:get).and_return(@cached_person)
    Person.cache_config = {:servers => "localhost:11211"}
  end

  after(:each) do
    Object.send(:remove_const, :Person)
  end
  
  it "should return a cached object, if present in memcache" do
    Person.should_receive(:cache).exactly(1).times.and_return(@mock_cache)
    @mock_cache.should_receive(:get).exactly(1).times.and_return(@cached_person)

    Person.get_cache("123").should == @cached_person
  end
end

describe "CanHasCached #get_cache method, with @cache_config set, but Memcached#get raises an error" do
  before(:each) do
    class Person
      include CanHasCached
    end
    
    @mock_cache = mock('Memcached')
    Person.stub!(:cache).and_return(@mock_cache)
    @mock_cache.stub!(:get).and_raise(Memcached::NotFound)
    Person.cache_config = {:servers => "localhost:11211"}
  end
  
  after(:each) do
    Object.send(:remove_const, :Person)
  end
  
  it "should return nil, if the Memcached object raises a Memcached::NotFound error" do
    Person.should_receive(:cache).exactly(1).times.and_return(@mock_cache)
    @mock_cache.should_receive(:get).exactly(1).times.and_raise(Memcached::NotFound)
    
    Person.get_cache("123").should == nil
  end
end