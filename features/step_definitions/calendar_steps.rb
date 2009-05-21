Given /^I am subscribed to "([^\"]*)"$/ do |calendar|
  cal = Calendar.find_by_name(calendar) || Calendar.make(:name => calendar)
  Permission.make :user => User.current_user, :calendar => cal
end

Given /^I am an admin(?:istrator)? of "([^\"]*)"$/ do |calendar|
  cal = Calendar.find_by_name(calendar) || Calendar.make(:name => calendar)
  Permission.make :user => User.current_user, :calendar => cal, :role => Role.make(:admin)
end