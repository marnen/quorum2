# coding: UTF-8

Given /^I am logged in$/ do
  user = FactoryGirl.create :user, :password => 'passw0rd'
  visit login_path
  fill_in('user_session[email]', :with => user.email)
  fill_in('user_session[password]', :with => 'passw0rd')
  click_button 'Log in'
  UserSession.find.record.should == user
end

Given /^I am not logged in$/ do
  User.current_user = false
end

Given /^there is no user account for "([^\"]*)"$/ do |email|
  u = User.find_by_email(email)
  if !u.nil?
    u.destroy
  end
end

Then /^I should (not )?have a user account for "([^\"]*)"$/ do |negation, email|
  user = User.find_by_email(email)
  if negation
    user.should be_nil
  else
    user.should_not be_nil
  end
end