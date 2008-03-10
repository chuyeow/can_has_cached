require File.dirname(__FILE__) + '/../spec_helper.rb'

describe "CanHasCached #cache_config, #cache_config= methods" do
  before(:each) do
    class Person
      include CanHasCached
    end
  end
  
  after(:each) do
    Object.send(:remove_const, :Person)
  end
  
  it "should return a nil cached_config, if not set" do
    Person.cache_config.should == nil
  end
  
  it "should be able to set cache_config with a Hash" do
    Person.cache_config = {:servers => "localhost:11211"}
    Person.cache_config.keys.should == [:servers]
  end
  
  it "should raise an error when trying to set cache_config with something other than a Hash" do
    lambda {Person.cache_config = '123'}.should raise_error(ArgumentError, "cache_config for CanHasCached must be a Hash")
  end
  
  it "should return the same cache_config as an object instantiated from the class" do
    Person.cache_config = {:servers => "localhost:11211"}
    Person.new.cache_config.should == Person.cache_config
  end
end
