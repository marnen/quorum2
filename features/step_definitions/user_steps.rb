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

Then /^I should have a user account for "([^\"]*)"$/ do |email|
  User.find_by_email(email).should_not be_nil
end