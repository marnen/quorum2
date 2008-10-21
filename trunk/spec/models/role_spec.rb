require File.dirname(__FILE__) + '/../spec_helper'

describe Role, "(general properties)" do
  before(:each) do
  end

  it "should have many Users" do
    Role.reflect_on_association(:users).macro.should == :has_many
  end
end

describe Role, "(validations)" do
  before(:each) do
    @role = Role.new
    @role.name = 'foo' # arbitrary value
  end
  
  it "should require a name" do
    @role.should be_valid
    @role.name = nil
    @role.should_not be_valid
  end
end