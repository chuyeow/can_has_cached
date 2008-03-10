require File.dirname(__FILE__) + '/../spec_helper.rb'

# Check if Base.extend works
describe "CanHasCached #extend" do
  before(:each) do
    class Person; include CanHasCached; end
  end
  
  after(:each) do
    Object.send(:remove_const, :Person)
  end
  
  it "should have 'allowed_options', 'cache_config', 'cache_config=', 'ttl', 'ttl=', 'cache_key', 'set_cache', 'get_cache' as class methods " do
    Person.methods.index('cache_config').should_not == nil
    Person.methods.index('cache_config=').should_not == nil
    Person.methods.index('ttl').should_not == nil
    Person.methods.index('ttl=').should_not == nil
    Person.methods.index('cache_key').should_not == nil
    Person.methods.index('set_cache').should_not == nil
    Person.methods.index('get_cache').should_not == nil
  end
end
