require File.dirname(__FILE__) + '/../spec_helper.rb'

describe "CanHasCached #include" do
  before(:each) do
    class Person; include CanHasCached; end
    @person = Person.new
  end
  
  after(:each) do
    Object.send(:remove_const, :Person)
  end
  
  it "should have 'cache_config', 'get_cache' and 'set_cache' as instance methods" do
    @person.methods.index('cache_config').should_not == nil
    @person.methods.index('get_cache').should_not == nil
    @person.methods.index('set_cache').should_not == nil
    
    @person.methods.index('ttl').should == nil
  end
end
