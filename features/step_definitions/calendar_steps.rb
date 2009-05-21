Given /^I am subscribed to "([^\"]*)"$/ do |calendar|
  cal = Calendar.find_by_name(calendar) || Calendar.make(:name => calendar)
  Permission.make :user => User.current_user, :calendar => cal
end

Given /^I am an admin(?:istrator)? of "([^\"]*)"$/ do |calendar|
  cal = Calendar.find_by_name(calendar) || Calendar.make(:name => calendar)
  Permission.make :user => User.current_user, :calendar => cal, :role => Role.make(:admin)
end

Then /^I should have a calendar called "([^\"]*)"$/ do |calendar|
  Calendar.find_by_name(calendar).should_not be_nil
end

Then /^I should be an admin(?:istrator)? of "([^\"]*)"$/ do |calendar|
  admin = Role.find_or_create_by_name('admin')
  cal = Calendar.find_by_name(calendar)
  User.current_user.permissions.find_by_calendar_id_and_role_id(cal.id, admin.id).should_not be_nil
end