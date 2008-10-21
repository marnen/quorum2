require File.dirname(__FILE__) + '/../spec_helper'

describe Permission, "(general properties)" do
  it "should belong to a User" do
    Permission.reflect_on_association(:user).macro.should == :belongs_to
  end
  
  it "should belong to a Calendar" do
    Permission.reflect_on_association(:calendar).macro.should == :belongs_to
  end

  it "should belong to a Role" do
    Permission.reflect_on_association(:role).macro.should == :belongs_to
  end
end

describe Permission, "(validations)" do
  before(:each) do
    @permission = Permission.new
    @permission.calendar_id = 1 # arbitrary
    @permission.user_id = 5 # arbitrary
    @permission.role_id = 'foo' # arbitrary
  end

  it "should not be valid without a calendar" do
    @permission.should be_valid
    @permission.calendar_id = nil
    @permission.should_not be_valid
  end

  it "should not be valid without a user" do
    @permission.should be_valid
    @permission.user_id = nil
    @permission.should_not be_valid
  end

  it "should not be valid without a role" do
    @permission.should be_valid
    @permission.role_id = nil
    @permission.should_not be_valid
  end
end

