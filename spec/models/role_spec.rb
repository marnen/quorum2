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

describe Role, "(to_s)" do
  before(:each) do
    @role = Role.new
    @role.name = 'foo' # arbitrary value
  end
  
  it "should return the Role's name, piped through gettext translate" do
    @role.to_s.should == @role.name # Not sure how to call _ from specs.
  end
end