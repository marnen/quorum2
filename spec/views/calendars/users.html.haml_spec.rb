# coding: UTF-8

require 'spec_helper'

include ERB::Util

describe "/calendars/users" do
  before(:each) do
    @calendar = FactoryGirl.create :calendar

    Role.destroy_all
    @admin_role = FactoryGirl.create :admin_role
    @user_role = FactoryGirl.create :role

    @admin = FactoryGirl.attributes_for :permission, :calendar => @calendar, :role => @admin_role, :user => nil
    @user = FactoryGirl.attributes_for :permission, :calendar => @calendar, :role => @user_role, :user => nil

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

  it "should show the results in a table" do
    rendered.should have_selector("table.users")
  end

  it "should show first and last names for each user" do
    for u in @users
      rendered.should have_selector("tr#user_#{u.id} td._name", :content => u.firstname)
      rendered.should have_selector("tr#user_#{u.id} td._name", :content => u.lastname)
    end
  end

  it "should show street and e-mail addresses for each user who has not requested to be hidden" do
    @users.each do |u|
      Capybara.string(rendered).find("tr#user_#{u.id}").tap do |row|
        if u.show_contact?
          row.find('td._address').tap do |address|
            address.text.should =~ Regexp.new([u.street, u.street2, "#{u.city}, #{u.state.code}"].collect{|x| Regexp.escape(h x)}.join('.*'))
            address.should have_selector 'br'
          end
          row.should have_selector('td._email', :content => u.email)
        else
          row.should have_selector("td._address", :content => "")
          row.should_not have_selector("td._email *", :content => u.email)
        end
      end
    end
  end

  it "should show each user's role in this calendar, and -- except for the current user -- should allow it to be changed" do
    for u in @users
      Capybara.string(rendered).find("tr#user_#{u.id}").tap do |row|
        if u == User.current_user
          row.should have_selector("td._role", :content => /admin/) # just text
          row.should_not have_selector("td._role select" )
        else
          row.should have_selector("td._role select" )
        end
      end
    end
  end

  it "should show whether each user is visible on commitment reports" do
    for u in @users
      rendered.should have_selector("tr#user_#{u.id} td._show input[type=checkbox]")
    end
  end
end
