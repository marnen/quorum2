# coding: UTF-8

require 'spec_helper'

def user_role
  simple_matcher('a user Role object') do |given|
    given.instance_of? Role and given.name == 'user'
  end
end

def admin_role
  simple_matcher('an admin Role object') do |given|
    given.instance_of? Role and given.name == 'admin'
  end
end

describe AdminController, "(index)" do
  render_views
  
  before(:each) do
    @one = FactoryGirl.create :calendar, :id => 1
    @two = FactoryGirl.create :calendar, :id => 2
    Role.destroy_all(:name => 'admin')

    @current_user = Factory(:user).tap do |u|
      u.permissions << Factory(:permission, :calendar => @one, :user => u)
      u.permissions << Factory(:admin_permission, :calendar => @two, :user => u)
    end
    
    UserSession.create @current_user
    get :index
  end
  
  it "should set the page title" do
    assigns[:page_title].should_not be_nil
  end
  
  it "should show a list of calendars for which the current user is an administrator, along with edit and users links" do
    assigns[:calendars].should_not be_nil
    assigns[:calendars].should include(@two)
    assigns[:calendars].should_not include(@one)
    response.body.should have_selector('li#calendar_2 a', :content => 'users')
  end
end
