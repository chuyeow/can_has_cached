require File.dirname(__FILE__) + '/../spec_helper.rb'

describe "CanHasCached #cache method, with @cache_config not set" do
  before(:each) do
    class Person
      include CanHasCached
    end
  end
  
  after(:each) do
    Object.send(:remove_const, :Person)
  end
  
  it "should raise an error while trying to call the #cache class method" do
    lambda { Person.cache }.should raise_error(ArgumentError, "cache_config must be set before you can use CanHasCached")
  end

  it "should raise an error while trying to call the #cache instance method" do
    lambda { Person.new.cache }.should raise_error(ArgumentError, "cache_config must be set before you can use CanHasCached")
  end

end

describe "CanHasCached #cache method, with @cache_config set" do
  before(:each) do
    class Person
      include CanHasCached
    end
    
    Person.cache_config = {:servers => "localhost:11211"}
    @mock_cache = mock('Memcached')
    Memcached.stub!(:new).and_return(@mock_cache)
  end
  
  after(:each) do
    Object.send(:remove_const, :Person)
  end
  
  it "should call the new method on the Memcached class, and return a Cache object" do
    Memcached.should_receive(:new).exactly(1).times.and_return(@mock_cache)
    Person.cache.should == @mock_cache
  end
  
  it "should call the class method #cache method, if the instance method #cache is called" do
    Person.new.cache.should == @mock_cache
  end
end


describe "CanHasCached #cache method, with @cache_config set, and the #cache method is called once already" do
  before(:each) do
    class Person
      include CanHasCached
    end
    
    Person.cache_config = {:servers => "localhost:11211"}
    @mock_cache = mock('Memcached')
    Memcached.stub!(:new).and_return(@mock_cache)
  end
  
  after(:each) do
    Object.send(:remove_const, :Person)
  end

  it "should call the new method on the Memcached class only once, the second time the cache method is called, the Memcached object must be initialized already" do
    Memcached.should_receive(:new).exactly(1).times.and_return(@mock_cache)
    Person.cache.should == @mock_cache
    # After calling #cache once, it should not called Memcached.new again
    Memcached.should_receive(:new).exactly(0).times
    Person.cache.should == @mock_cache
  end
  
  it "should call the class method #cache method, if the instance method #cache is called" do
    Memcached.should_receive(:new).exactly(1).times.and_return(@mock_cache)
    Person.cache.should == @mock_cache
    # After calling #cache once, it should not called Memcached.new again
    Memcached.should_receive(:new).exactly(0).times
    Person.new.cache.should == @mock_cache
  end
end  