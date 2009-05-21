Given /^there are no events$/ do
  Event.destroy_all
end

Then /^I should have an event called "([^\"]*)" in "([^\"]*)"$/ do |name, calendar|
  cal = Calendar.find_by_name(calendar)
  cal.should_not be_nil
  Event.find_by_name_and_calendar_id(name, cal.id).should_not be_nil
end