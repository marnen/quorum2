# coding: UTF-8

Given /^there are no events$/ do
  Event.destroy_all
end

Given /^I have an event called "([^\"]*)" in "([^\"]*)"$/ do |name, calendar|
  cal = Calendar.find_by_name(calendar) || FactoryGirl.create(:calendar, :name => calendar)
  e = create_model :event, :name => name, :calendar => cal, :date => Time.now + 10.years # so it will show up on default event list
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
  event = model! :event
  page.should have_selector '#map'
  page.should have_selector '#lat', text: event.latitude.to_s
  page.should have_selector '#lng', text: event.longitude.to_s
end

Then /^I should see an event with the following text:$/ do |table|
  strings = table.raw.flatten
  strings *= 2 if strings.size == 1
  within '.event', text: strings.shift do
    strings.each do |string|
      page.should have_content string
    end
  end
end