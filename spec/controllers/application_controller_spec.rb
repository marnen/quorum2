# coding: UTF-8

require 'spec_helper'

describe ApplicationController, "(admin?)" do
  it "should return nil if current user is nil or false" do
    UserSession.create nil
    controller.admin?.should be_nil
    UserSession.create false
    controller.admin?.should be_nil
  end

  it "should return true if current user is an admin" do
    admin_role = FactoryGirl.create :admin_role
    Role.should_receive(:find_by_name).with('admin').and_return admin_role
    @admin = FactoryGirl.create(:user).tap {|u| u.permissions << FactoryGirl.create(:admin_permission, :user => u, :role => admin_role) }
    UserSession.create @admin
    controller.admin?.should be_true
  end

  it "should return false if current user is not an admin" do
    @user = FactoryGirl.create(:user).tap {|u| u.permissions << FactoryGirl.create(:permission, :user => u) }
    UserSession.create @user
    controller.admin?.should be_false
  end
end
