require File.dirname(__FILE__) + '/../spec_helper'

describe ApplicationController, "(admin?)" do
  it "should return nil if current user is nil or false" do
    UserSession.create nil
    controller.admin?.should be_nil
    UserSession.create false
    controller.admin?.should be_nil
  end
  
  it "should return true if current user is an admin" do
    @admin = User.make do |u|
      u.permissions.make(:role => Role.make(:admin))
    end
    UserSession.create @admin
    controller.admin?.should be_true
  end
  
  it "should return false if current user is not an admin" do
    @user = User.make do |u|
      u.permissions.make(:role => Role.make)
    end
    UserSession.create @user
    controller.admin?.should be_false
  end
end
