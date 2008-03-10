require File.dirname(__FILE__) + '/../spec_helper.rb'

describe "CanHasCached #cache_key method, with @cache_config not set" do
  before(:each) do
    class Person
      include CanHasCached
    end
  end
  
  after(:each) do
    Object.send(:remove_const, :Person)
  end
  
  it "should set the cache key correctly" do
    Person.cache_key("123").should == "Person:123"
  end
end
  
describe "CanHasCached #cache_key method, with @cache_config set" do
  before(:each) do
    class Person
      include CanHasCached
    end
    
    Person.cache_config = {:servers => "localhost:11211"}
  end

  after(:each) do
    Object.send(:remove_const, :Person)
  end
  
  it "should set the cache_key with no error" do
    Person.cache_key("123").should == "Person:123"
  end
  
end

describe "CanHasCached #cache_key method, with @cache_config with version set correctly" do
  before(:each) do
    class Person
      include CanHasCached
    end
    
    Person.cache_config = {:servers => "localhost:11211", :version => 1.0}
  end

  after(:each) do
    Object.send(:remove_const, :Person)
  end

  it "should set the cache_key with no errors" do
    Person.cache_key("123").should == "Person:1.0:123"
  end
end