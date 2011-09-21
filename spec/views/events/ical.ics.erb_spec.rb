# coding: UTF-8

require 'spec_helper'
include EventsHelper

describe "/events/ical.ics" do
  before(:each) do
    @event = Factory :event
    assign :event, @event
    render :file => 'events/ical.ics.erb'
  end
  
  it "should contain the iCal UID" do
    rendered.should have_content("UID:#{ical_uid @event}")
  end
  
  it "should contain the event name as a summary" do
    rendered.should have_content("SUMMARY:#{ical_escape @event.name}")
  end
  
  it "should contain the event address as location" do
    rendered.should have_content("LOCATION:#{[@event.street, @event.street2, @event.city, @event.state.code, @event.country.code].compact.join(', ')}")
  end
  
  it "should contain the event description as description" do
    rendered.should have_content("DESCRIPTION:#{ical_escape @event.description}")
  end
  
  it "should contain the date in iCal format" do
    rendered.should have_content("DTSTART;VALUE=DATE:#{@event.date.to_s :ical}")
  end
end
