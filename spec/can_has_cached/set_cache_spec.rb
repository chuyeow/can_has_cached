require File.dirname(__FILE__) + '/../spec_helper.rb'

describe "CanHasCached #set_cache method, with @cache_config not set" do
  before(:each) do
    class Person
      include CanHasCached
    end
  end
  
  after(:each) do
    Object.send(:remove_const, :Person)
  end
  
  it "should raise an error if cache_config is not set" do
    lambda { Person.set_cache("123", 123) }.should raise_error(ArgumentError, "cache_config must be set before you can use CanHasCached")
  end
end

describe "CanHasCached #set_cache method, with @cache_config set correctly" do
  before(:each) do
    class Person
      include CanHasCached
    end
    
    @mock_cache = mock('Memcached')
    Person.stub!(:cache).and_return(@mock_cache)
    @mock_cache.stub!(:set).and_return(0)
    
    Person.cache_config = {:servers => "localhost:11211"}
  end
  
  after(:each) do
    Object.send(:remove_const, :Person)
  end
  
  it "should call the set method on the Memcached object" do
    Person.should_receive(:cache).exactly(1).times.and_return(@mock_cache)
    @mock_cache.should_receive(:set).exactly(1).times.and_return(0)
    
    Person.set_cache("123", 123).should == 0
  end
end
