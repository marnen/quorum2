# coding: UTF-8

require 'spec_helper'

include ERB::Util

describe "/calendars/users" do
  before(:each) do
    @calendar = FactoryGirl.create :calendar

    Role.destroy_all
    @admin_role = FactoryGirl.create :admin_role
    @user_role = FactoryGirl.create :role

    @admin = FactoryGirl.build(:permission, :calendar => @calendar, :role => @admin_role, :user => nil).attributes
    @user = FactoryGirl.build(:permission, :calendar => @calendar, :role => @user_role, :user => nil).attributes

    @marnen = FactoryGirl.create(:user, :show_contact => true).tap do |u|
      u.permissions.destroy_all
      u.permissions.create!(@admin.merge :user => u)
    end
    @millie = FactoryGirl.create(:user, :show_contact => true).tap do |u|
      u.permissions.destroy_all
      u.permissions.create!(@user.merge :user => u)
    end
    @quentin = FactoryGirl.create(:user, :show_contact => false).tap do |u|
      u.permissions.destroy_all
      u.permissions.create!(@user.merge :user => u)
    end
    @users = [@millie, @marnen, @quentin]
    User.stub!(:current_user).and_return(@marnen)

    assign :users, @users
    assign :current_object, @calendar
    render :file => 'calendars/users'
  end

  it "should show whether each user is visible on commitment reports" do
    for u in @users
      rendered.should have_selector("tr#user_#{u.id} td._show input[type=checkbox]")
    end
  end
end
