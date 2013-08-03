# coding: UTF-8

Given /^(I|"[^\"]*") (?:am|is) subscribed to "([^\"]*)"$/ do |user, calendar|
  if user == 'I'
    user = User.current_user
  else
    names = user.gsub(/^"|"$/, '').split(' ', 2)
    user = Factory :user, :firstname => names.first, :lastname => names.last
  end
  cal = fetch_calendar calendar
  Permission.destroy(cal.permissions.find_all_by_user_id(user.id).collect(&:id)) # make sure we don't have any superfluous admin permissions hanging around
  FactoryGirl.create :permission, :user => user, :calendar => cal
end

Given /^I am an admin(?:istrator)? of "([^\"]*)"$/ do |calendar|
  cal = fetch_calendar calendar
  FactoryGirl.create :permission, :user => UserSession.find.record, :calendar => cal, :role => FactoryGirl.create(:admin_role)
end

Given /^someone else has a calendar called "([^\"]*)"$/ do |calendar|
  cal = fetch_calendar calendar
  Permission.destroy(cal.permissions.find_all_by_user_id(User.current_user.id).collect(&:id)) # make sure we don't have any superfluous admin permissions hanging around
  Factory :admin_permission, :calendar => cal
end

Given /^no calendars exist$/ do
  Calendar.destroy_all
end

Then /^I should have a calendar called "([^\"]*)"$/ do |calendar|
  Calendar.find_by_name(calendar).should_not be_nil
end

Then /^I should be an admin(?:istrator)? of "([^\"]*)"$/ do |calendar|
  admin = Role.find_or_create_by_name('admin')
  cal = fetch_calendar calendar
  User.current_user.permissions.find_by_calendar_id_and_role_id(cal.id, admin.id).should_not be_nil
end

Then /^I should (not )?be subscribed to "([^"]*)"$/ do |negation, calendar|
  visit subscriptions_path
  within '.subscriptions' do
    page.has_content?(calendar).should == !negation
  end
end