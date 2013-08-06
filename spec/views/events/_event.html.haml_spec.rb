# coding: UTF-8

require 'spec_helper'

include ERB::Util
include ActionView::Helpers::UrlHelper
include EventsHelper

describe 'events/_event' do
  before(:each) do
    Role.destroy_all(:name => 'admin')
    @event = FactoryGirl.create :event, :description => 'Testing use of *Markdown*.'
    @user = FactoryGirl.create :user
    [User, view].each {|x| x.stub!(:current_user).and_return @user }
  end

  it "should contain a distance in miles or km for the event if it has good coords" do
    render_view
    if !@event.coords.nil? then
      rendered.should have_selector("#event_#{@event.id} .distance", :content => /\d (miles|km)/)
    end
  end

  it "should show the name of the event in a tag of class 'summary'" do
    render_view
    rendered.should have_selector("#event_#{@event.id} .summary", :content => @event.name)
  end

  it "should show the description of the event (formatted with Markdown) in a tag of class 'description'" do
    render_view
    selector = "#event_#{@event.id} .description"
    rendered.should have_selector(selector, :content => /Testing use of/)
    rendered.should have_selector("#{selector} em", :content => 'Markdown')
  end

  it "should show the site for the event" do
    render_view
    rendered.should have_selector("#event_#{@event.id}", :content => @event.site)
  end

  it "should show the street address of the event in a tag of class 'street-address" do
    render_view
    rendered.should have_selector("#event_#{@event.id} .street-address", :content => /#{[h(@event.street), h(@event.street2)].join('.*')}/m)
  end

  it "should show the city of the event in a tag of class 'locality'" do
    render_view
    rendered.should have_selector("#event_#{@event.id} .locality", :content => @event.city)
  end

  it "should show the state code of the event in a tag of class 'region'" do
    render_view
    rendered.should have_selector("#event_#{@event.id} .region", :content => @event.state.code)
  end

  it "should show the country code of each event in a tag of class 'country-name'" do
    render_view
    rendered.should have_selector("#event_#{@event.id} .country-name", :content => @event.country.code)
  end

  it "should show the zip code of each event in a tag of class 'postal-code'" do
    render_view
    rendered.should have_selector("#event_#{@event.id} .postal-code", :content => @event.zip)
  end

  it "should show a map link for the event" do
    render_view
    url = url_for(:controller => 'events', :action => 'map', :id => @event.id, :escape => false)
    rendered.should have_selector("#event_#{@event.id} a[href='#{url}']")
  end

  it "should show an iCal export link for the event, of class 'ical'" do
    render_view
    url = url_for(:controller => 'events', :action => 'export', :id => @event.id, :escape => false)
    rendered.should have_selector("#event_#{@event.id} a.ical[href='#{url}']")
  end

  it "should show a date for the event in RFC 822 format, wrapped in an <abbr> of class 'dtstart' with ical-style date as the title" do
    render_view
    date = @event.date
    rendered.should have_selector("#event_#{@event.id} abbr.dtstart[title='#{date.to_formatted_s(:ical)}']", :content => date.to_formatted_s(:rfc822))
  end

  it "should have an element of class 'uid' for each event, containing an iCal unique ID for the event" do
    render_view
    rendered.should have_selector("#event_#{@event.id} .uid", :content => ical_uid(@event))
  end

  it "should get a list of users attending and not attending for each event" do
    # TODO: figure out why each find_committed call is happening 3 times
    @event.should_receive(:find_committed).with(:yes).at_least(:once).and_return([])
    @event.should_receive(:find_committed).with(:no).at_least(:once).and_return([])
    render_view
  end

  it "should show the number of users attending and not attending each event" do
    pending "not sure how to spec this"
  end

 protected
  def render_view
    render :partial => 'events/event', :locals => {:event => @event}
  end
end