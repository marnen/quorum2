# coding: UTF-8

Given /^a user named "([^"]*)" exists with email "([^"]*)"$/ do |full_name, email|
  user_by_name full_name, email: email
end

Given /^a user exists with #{capture_fields}, single access token: "([^"]*)"$/ do |fields, token|
  create_model :user, parse_fields(fields).merge('single_access_token' => token)
end

Given /^user "([^"]*)" has the following address:$/ do |full_name, table|
  address = table.rows_hash
  state_code = {code: address.delete('state')}
  address['state'] = Acts::Addressed::State.where(state_code).first || create_model(:state, state_code)
  user_by_name full_name, address
end

Given /^user "([^"]*)" does (not )?hide his address$/ do |full_name, negation|
  user_by_name full_name, show_contact: !!negation
end

Given /^I am logged in as "([^"]*)"$/ do |email|
  user = User.find_by_email email
  login_as user
end

Given /^I am logged in$/ do
  user = create_model :user, :password => 'passw0rd'
  login_as user
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

private

def login_as(user)
  visit login_path
  fill_in('user_session[email]', :with => user.email)
  fill_in('user_session[password]', :with => 'passw0rd')
  click_button 'Log in'
  UserSession.find.record.should == user
end