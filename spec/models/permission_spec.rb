require 'spec_helper'

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
    @permission = Permission.make!
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
  
  it "should be unique across all three attributes" do
    opts = Permission.plan
    @one = Permission.new opts
    @one.should be_valid
    @one.save!
    @two = Permission.new opts
    @two.should_not be_valid
    [:calendar_id, :user_id, :role_id].each do |attr|
      @three = Permission.new opts
      @three[attr] += 1
      @three.should be_valid
    end
  end
end

