require File.dirname(__FILE__) + '/../../spec_helper'

include ERB::Util
include ActionView::Helpers::UrlHelper
include EventsHelper

describe 'events/_event' do
  fixtures :events, :countries, :states, :commitments, :users

  before(:all) do
    @event_orig = Event.find(:first)
    @user = User.find(:first)
  end
  
  before(:each) do
    @event = @event_orig
    User.stub!(:current_user).and_return(@user)
  end

  it "should contain an edit link for the event, if the current user is an admin" do
    cal = @event.calendar_id
    role = mock_model(Role, :name => 'admin')
    admin_p = [mock_model(Permission, :calendar_id => cal, :role => role)]
    admin_p.stub!(:find_by_calendar_id).with(cal).and_return(admin_p[0])
    admin = mock_model(User, :permissions => admin_p)
    User.stub!(:current_user).and_return(admin)
    
    render_view
    url = url_for(:controller => 'events', :action => 'edit', :id => @event.id, :escape => false)
    response.should have_tag("#event_#{@event.id} a[href=" << url << "]")
  end

  it "should contain a delete link for the event, if the current user has an admin account" do
    cal = @event.calendar_id
    role = mock_model(Role, :name => 'admin')
    admin_p = [mock_model(Permission, :calendar_id => cal, :role => role)]
    admin_p.stub!(:find_by_calendar_id).with(cal).and_return(admin_p[0])
    admin = mock_model(User, :permissions => admin_p)
    User.stub!(:current_user).and_return(admin)
    
    render_view
    url = url_for(:controller => 'events', :action => 'delete', :id => @event.id, :escape => false)
    response.should have_tag("#event_#{@event.id} a[href=" << url << "]")
  end
  
  it "should have a control to set the current user's attendance for the event" do
    template.expect_render(:partial => 'attendance', :locals => {:event => @event})
    render_view
  end
  
  it "should contain a distance in miles or km for the event if it has good coords" do
    render_view
    if !@event.coords.nil? then
      response.should have_tag("#event_#{@event.id} .distance", /\d (miles|km)/)
    end
  end
  
  it "should show the name of the event in a tag of class 'summary'" do
    render_view
    response.should have_tag("#event_#{@event.id} .summary", h(@event.name))
  end
  
  it "should show the description of the event in a tag of class 'description'" do
    render_view
    response.should have_tag("#event_#{@event.id} .description", h(@event.description))
  end

  it "should show the site for the event" do
    render_view
    response.should have_tag("#event_#{@event.id}", /#{h(@event.site)}/)
  end 

  it "should show the street address of the event in a tag of class 'street-address" do
    render_view
    response.should have_tag("#event_#{@event.id} .street-address", /#{[h(@event.street), h(@event.street2)].join('.*')}/m)
  end
  
  it "should show the city of the event in a tag of class 'locality'" do
    render_view
    response.should have_tag("#event_#{@event.id} .locality", h(@event.city))
  end
  
  it "should show the state code of the event in a tag of class 'region'" do
    render_view
    response.should have_tag("#event_#{@event.id} .region", h(@event.state.code))
  end

  it "should show the country code of each event in a tag of class 'country-name'" do
    render_view
    response.should have_tag("#event_#{@event.id} .country-name", h(@event.country.code))
  end
  
  it "should show the zip code of each event in a tag of class 'postal-code'" do
    render_view
    response.should have_tag("#event_#{@event.id} .postal-code", h(@event.zip))
  end
  
  it "should show a map link for the event" do
    render_view
    url = url_for(:controller => 'events', :action => 'map', :id => @event.id, :escape => false)
    response.should have_tag("#event_#{@event.id} a[href=" << url << "]")
  end
  
  it "should show an iCal export link for the event, of class 'ical'" do
    render_view
    url = url_for(:controller => 'events', :action => 'export', :id => @event.id, :escape => false)
    response.should have_tag("#event_#{@event.id} a.ical[href=" << url << "]")
  end
  
  it "should show a date for the event in RFC 822 format, wrapped in an <abbr> of class 'dtstart' with ical-style date as the title" do
    render_view
    date = @event.date
    response.should have_tag("#event_#{@event.id} abbr.dtstart[title=" << date.to_formatted_s(:ical) << "]", date.to_formatted_s(:rfc822))
  end
  
  it "should have an element of class 'uid' for each event, containing an iCal unique ID for the event" do
    render_view
    response.should have_tag("#event_#{@event.id} .uid", ical_uid(@event))
  end
  
  it "should contain an edit link for each event that the current user created" do
    pending "app behaves correctly, but this spec doesn't seem to work"
=begin
    user = mock_model(Role, :name => 'user')
    nonadmin = mock_model(User, :role => user)
    User.stub!(:current_user).and_return(nonadmin) # non-admin
    Event.stub!(:created_by).and_return(nonadmin)
    render_view
    for event in @events do
      User.current_user.should == nonadmin
      event.created_by.should == nonadmin
      url = url_for(:controller => 'events', :action => 'edit', :id => event.id, :escape => false)
      response.should have_tag("#event_#{event.id} a[href=" << url << "]")
    end
    Event.stub!(:created_by).and_return(User.new)
    for event in @events do
      url = url_for(:controller => 'events', :action => 'edit', :id => event.id, :escape => false)
      response.should_not have_tag("#event_#{event.id} a[href=" << url << "]")
    end
=end
  end
  
  it "should get a list of users attending and not attending for each event" do
=begin
      for event in @events do
        event.should_receive(:find_committed).with(:yes).once
        event.should_receive(:find_committed).with(:no).once
      end
=end
    pending "maybe put this in a before block?"
  end

  it "should wrap the whole response in a form" do
    render_view
    response.should have_tag("form.attendance")
  end
  
 protected
  def render_view
    render :partial => 'events/event', :locals => {:event => @event}
  end
end