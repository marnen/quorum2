Given /^I am logged in$/ do
  user = User.make(:password => 'passw0rd')
  visit login_path
  fill_in(:email, :with => user.email)
  fill_in(:password, :with => 'passw0rd')
  click_button
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

Then /^I should have a user account for "([^\"]*)"$/ do |email|
  User.find_by_email(email).should_not be_nil
end