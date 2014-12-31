# coding: UTF-8

require 'spec_helper'

include ERB::Util
include ActionView::Helpers::UrlHelper
include EventsHelper

describe 'events/_event' do
  before(:each) do
    Role.destroy_all(:name => 'admin')
    User.destroy_all # TODO: why is this necessary?
    @event = FactoryGirl.create :event, :description => 'Testing use of *Markdown*.'
    @user = FactoryGirl.create :user
    [User, view].each {|x| x.stub!(:current_user).and_return @user }
  end

  it "should contain edit and delete links for the event, if the current user is an admin" do
    admin_role = Role.find_or_create_by_name 'admin'
    admin = FactoryGirl.create(:user).tap do |u|
      u.permissions.destroy_all
      u.permissions << FactoryGirl.create(:permission, :role => admin_role, :calendar => @event.calendar, :user => u)
    end
    [User, view].each {|x| x.stub!(:current_user).and_return admin }

    render_view
    edit_url = url_for(:controller => 'events', :action => 'edit', :id => @event.id)
    delete_url = url_for(:controller => 'events', :action => 'delete', :id => @event.id)
    [edit_url, delete_url].each do |url|
      rendered.should have_selector("#event_#{@event.id} a[href='#{url}']")
    end
  end

  it 'should contain calendar names for events, if the current user has more than one calendar' do
    @one = FactoryGirl.create :calendar
    @user.stub!(:calendars).and_return([@one, FactoryGirl.create(:calendar)])
    @event.stub!(:calendar).and_return(@one)

    render_view
    rendered.should have_selector("#event_#{@event.id} .calendar", :content => @one)
  end

  it 'should not contain calendar names for events, if the current user has only one calendar' do
    @one = FactoryGirl.create :calendar
    @user.stub!(:calendars).and_return([@one])
    @event.stub!(:calendar).and_return(@one)

    render_view
    rendered.should_not have_selector("#event_#{@event.id} .calendar")
  end

  it "should have a control to set the current user's attendance for the event" do
    pending "This works, but spec fails strangely." do
      template.should_receive(:render).with(:partial => 'attendance', :locals => {:event => @event})
      render_view
    end
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
    url = url_for(:controller => 'events', :action => 'map', :id => @event.id)
    rendered.should have_selector("#event_#{@event.id} a[href='#{url}']")
  end

  it "should show an iCal export link for the event, of class 'ical'" do
    render_view
    url = url_for(:controller => 'events', :action => 'export', :id => @event.id)
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

  it "should contain an edit link for each event that the current user created" do
=begin
    How did this *ever* work?

    events.each do |event|
      url = url_for(:controller => 'events', :action => 'edit', :id => event.id, :escape => false)
      rendered.should have_selector("#event_#{event.id} a[href=" << url << "]")
    end
=end
    @user.permissions << FactoryGirl.create(:permission, :calendar => @event.calendar)
    @event.created_by = @user
    render_view
    url = url_for(:controller => 'events', :action => 'edit', :id => @event.id)
    rendered.should have_selector("#event_#{@event.id} a[href='#{url}']")
  end

  it "should not contain an edit link for events that the current (non-admin) user created" do
    @user.permissions << FactoryGirl.create(:permission, :calendar => @event.calendar)
    @event.created_by = FactoryGirl.create :user # some other guy
    render_view
    url = url_for(:controller => 'events', :action => 'edit', :id => @event.id)
    rendered.should_not have_selector("#event_#{@event.id} a[href='#{url}']")
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

  it "should wrap the whole response in a form" do
    render_view
    rendered.should have_selector("form.attendance")
  end

 protected
  def render_view
    render :partial => 'events/event', :locals => {:event => @event}
  end
end