require 'spec_helper'
include EventsHelper

describe "/events/ical.ics" do
  before(:each) do
    @event = Factory :event
    assigns[:event] = @event
    render 'events/ical.ics.erb'
  end
  
  it "should contain the iCal UID" do
    response.should have_text(/UID:#{ical_uid @event}/)
  end
  
  it "should contain the event name as a summary" do
    response.should have_text(/SUMMARY:#{ical_escape @event.name}/)
  end
  
  it "should contain the event address as location" do
    response.should have_text(/LOCATION:#{[@event.street, @event.street2, @event.city, @event.state.code, @event.country.code].compact.join(', ')}/)
  end
  
  it "should contain the event description as description" do
    response.should have_text(/DESCRIPTION:#{ical_escape @event.description}/)
  end
  
  it "should contain the date in iCal format" do
    response.should have_text(/DTSTART;VALUE=DATE:#{@event.date.to_s :ical}/)
  end
end
