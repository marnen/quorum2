Given /^there are no events$/ do
  Event.destroy_all
end

Given /^I have an event called "([^\"]*)" in "([^\"]*)"$/ do |name, calendar|
  cal = Calendar.find_by_name(calendar) || FactoryGirl.create(:calendar, :name => calendar)
  e = FactoryGirl.create :event, :name => name, :calendar => cal, :date => Time.now + 10.years # so it will show up on default event list
  e.created_by = User.current_user
  e.save!
end

Given /^someone else has an event called "([^\"]*)" in "([^\"]*)"$/ do |name, calendar|
  cal = Calendar.find_by_name(calendar) || FactoryGirl.create(:calendar, :name => calendar)
  e = FactoryGirl.create :event, :name => name, :calendar => cal, :date => Time.now + 10.years # so it will show up on default event list
  e.created_by = FactoryGirl.create :user
  e.save!
end

Then /^I should have an event called "([^\"]*)" in "([^\"]*)"$/ do |name, calendar|
  cal = Calendar.find_by_name(calendar)
  cal.should_not be_nil
  Event.find_by_name_and_calendar_id(name, cal.id).should_not be_nil
end

Then /^I should see a map of the event$/ do
  Then 'I should see an element matching "#map"'
end