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