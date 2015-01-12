# coding: UTF-8

require 'spec_helper'
include EventsHelper

describe "/events/ical.ics" do
  before(:each) do
    @event = FactoryGirl.create :event
    assign :event, @event
    render file: 'events/ical', formats: [:ics], handlers: [:erb]
  end

  it "should use Windows line ends" do
    rendered.should include("#{13.chr}#{10.chr}")
    rendered.should_not =~ /[^#{13.chr}]#{10.chr}/
  end

  it "should countain a product identifier" do
    rendered.should have_content("PRODID:-//quorum2.sf.net//#{SITE_TITLE} #{APP_VERSION}//EN")
  end

  it "should contain the iCal UID" do
    rendered.should have_content("UID:#{ical_uid @event}")
  end

  it "should contain the event name as a summary" do
    rendered.should have_content("SUMMARY:#{ical_escape @event.name}")
  end

  it "should contain the event address as location" do
    escaped_location = ical_escape [@event.street, @event.street2, @event.city, @event.state.code, @event.country.code].compact.join(', ')
    rendered.should have_content("LOCATION:#{escaped_location}")
  end

  it "should contain the event description as description" do
    rendered.should have_content("DESCRIPTION:#{ical_escape @event.description}")
  end

  it "should contain the date in iCal format" do
    rendered.should have_content("DTSTART;VALUE=DATE:#{@event.date.strftime '%Y%m%d'}")
  end
end
