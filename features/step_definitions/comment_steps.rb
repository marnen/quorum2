Given /^someone else has a comment for "([^"]*)" in "([^"]*)" with text "([^"]*)"$/ do |event, calendar, comment|
  calendar = fetch_calendar calendar
  event = fetch_event name: event, calendar: calendar
  FactoryGirl.create :commitment, event: event, comment: comment
end