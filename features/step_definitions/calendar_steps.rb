Given /^I am subscribed to "([^\"]*)"$/ do |calendar|
  cal = Calendar.find_by_name(calendar) || Calendar.make(:name => calendar)
  Permission.make :user => User.current_user, :calendar => cal
end