require File.dirname(__FILE__) + '/../spec_helper.rb'

describe "CanHasCached #ttl, #ttl= methods" do
  before(:each) do
    class Person
      include CanHasCached
    end
  end
  
  after(:each) do
    Object.send(:remove_const, :Person)
  end
  
  it "should return nil ttl, if not set" do
    Person.ttl.should == nil
  end
  
  it "should be able to set a valid ttl" do
    Person.ttl = 86400
    Person.ttl.should == 86400
  end
  
  it "should raise an error, if the argument for the ttl, is not an integer" do
    lambda {Person.ttl = '123'}.should raise_error(ArgumentError, "ttl for CanHasCached must be a Fixnum")    
  end
end
