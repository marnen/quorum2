require 'spec_helper'

describe ApplicationController, "(admin?)" do
  it "should return nil if current user is nil or false" do
    UserSession.create nil
    controller.admin?.should be_nil
    UserSession.create false
    controller.admin?.should be_nil
  end
  
  it "should return true if current user is an admin" do
    @admin = FactoryGirl.create :user, :permissions => [FactoryGirl.create :admin_permission]
    UserSession.create @admin
    controller.admin?.should be_true
  end
  
  it "should return false if current user is not an admin" do
    @user = FactoryGirl.create :user, :permissions => [FactoryGirl.create :permission]
    UserSession.create @user
    controller.admin?.should be_false
  end
end
