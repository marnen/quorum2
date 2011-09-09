require 'spec_helper'

describe ApplicationController, "(admin?)" do
  it "should return nil if current user is nil or false" do
    UserSession.create nil
    controller.admin?.should be_nil
    UserSession.create false
    controller.admin?.should be_nil
  end
  
  it "should return true if current user is an admin" do
    admin_role = Factory :admin_role
    Role.should_receive(:find_by_name).with('admin').and_return admin_role
    @admin = Factory(:user).tap {|u| u.permissions << Factory(:admin_permission, :user => u, :role => admin_role) }
    UserSession.create @admin
    controller.admin?.should be_true
  end
  
  it "should return false if current user is not an admin" do
    @user = Factory(:user).tap {|u| u.permissions << Factory(:permission, :user => u) }
    UserSession.create @user
    controller.admin?.should be_false
  end
end
