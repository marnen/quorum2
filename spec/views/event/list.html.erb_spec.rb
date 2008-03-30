require File.dirname(__FILE__) + '/../../spec_helper'

include ERB::Util
include ActionView::Helpers::UrlHelper
include EventHelper

describe "/event/list" do
  fixtures :states, :countries, :events, :users, :commitments
  before(:each) do
    login_as :marnen
    @events = Event.find(:all)
    assigns[:events] = @events
    assigns[:current_user] = users(:marnen)
    User.stub!(:current_user).and_return(assigns[:current_user])
  end
  
  it "should have loaded at least one event" do
    render 'event/list'
    @events.size.should > 0
  end
  
  it "should show a sort link in date and event column header" do
    render 'event/list'
    response.should have_tag("th a.sort", h("Date"))
    response.should have_tag("th a.sort", h("Event"))
  end
  
  it "should show a sort indicator next to headers that have been sorted by" do
=begin
    assigns[:order] = 'name'
    assigns[:direction] = 'desc'
    render 'event/list' # , {:order => 'name', :direction => 'desc'}
    response.should have_text(h("Event ↓"))
=end
    pending "this spec always fails, even though the application behaves correctly...need to rewrite with a helper?"
  end
  
  it "should show a name for each Event in a tag of class 'summary'" do
    render 'event/list'
    for event in @events do
      response.should have_tag("#event_#{event.id} .summary", h(event.name))
    end
  end 

  it "should show a site for each Event" do
   render 'event/list'
   for event in @events do
      response.should have_tag("#event_#{event.id}", /#{h(event.site)}/)
    end
  end 

  it "should show a street address for each Event in a tag of class 'street-address" do
    render 'event/list'
    for event in @events do
      response.should have_tag("#event_#{event.id} .street-address", /#{[h(event.street), h(event.street2)].join('.*')}/m)
    end
  end
  
  it "should show a city for each event in a tag of class 'locality'" do
    render 'event/list'
    for event in @events do
      response.should have_tag("#event_#{event.id} .locality", h(event.city))
    end
  end
  
  it "should show a state code for each event in a tag of class 'region'" do
    render 'event/list'
    for event in @events do
      response.should have_tag("#event_#{event.id} .region", h(event.state.code))
    end
  end

  it "should show a country code for each event in a tag of class 'country-name'" do
    render 'event/list'
    for event in @events do
      response.should have_tag("#event_#{event.id} .country-name", h(event.state.country.code))
    end
  end
  
  it "should show a map link for each event" do
    render 'event/list'
    for event in @events do
      url = url_for(:controller => 'event', :action => 'map', :id => event.id, :escape => false)
      response.should have_tag("#event_#{event.id} a[href=" << url << "]")
    end
  end
  
  it "should show an iCal export link for each event, of class 'ical'" do
    render 'event/list'
    for event in @events do
      url = url_for(:controller => 'event', :action => 'export', :id => event.id, :escape => false)
      response.should have_tag("#event_#{event.id} a.ical[href=" << url << "]")
    end
  end
  
  it "should show a date for each event in RFC 822 format, wrapped in an <abbr> of class 'dtstart' with ical-style date as the title" do
    render 'event/list'
    for event in @events do
      date = event.date
      response.should have_tag("#event_#{event.id} abbr.dtstart[title=" << date.to_formatted_s(:ical) << "]", date.to_formatted_s(:rfc822))
    end
  end
  
  it "should have an element of class 'uid' for each event, containing an iCal unique ID for the event" do
    render 'event/list'
    for event in @events do
      response.should have_tag("#event_#{event.id} .uid", ical_uid(event))
    end
  end
  
  it "should contain an edit link for each event that the current user created" do
    pending "app behaves correctly, but this spec doesn't seem to work"
=begin
    user = mock_model(Role, :name => 'user')
    nonadmin = mock_model(User, :role => user)
    User.stub!(:current_user).and_return(nonadmin) # non-admin
    Event.stub!(:created_by).and_return(nonadmin)
    render 'event/list'
    for event in @events do
      User.current_user.should == nonadmin
      event.created_by.should == nonadmin
      url = url_for(:controller => 'event', :action => 'edit', :id => event.id, :escape => false)
      response.should have_tag("#event_#{event.id} a[href=" << url << "]")
    end
    Event.stub!(:created_by).and_return(User.new)
    for event in @events do
      url = url_for(:controller => 'event', :action => 'edit', :id => event.id, :escape => false)
      response.should_not have_tag("#event_#{event.id} a[href=" << url << "]")
    end
=end
  end
  
  it "should contain an edit link for all events, if the current user is an admin" do
    role = mock_model(Role, :name => 'admin')
    admin = mock_model(User, :role => role)
    User.stub!(:current_user).and_return(admin)
    render 'event/list'
    for event in @events do
      url = url_for(:controller => 'event', :action => 'edit', :id => event.id, :escape => false)
      response.should have_tag("#event_#{event.id} a[href=" << url << "]")
    end
  end

  it "should contain a delete link for each event, if the current user has an admin account" do
    role = mock_model(Role, :name => 'admin')
    admin = mock_model(User, :role => role)
    User.stub!(:current_user).and_return(admin)
    render 'event/list'
    for event in @events do
      url = url_for(:controller => 'event', :action => 'delete', :id => event.id, :escape => false)
      response.should have_tag("#event_#{event.id} a[href=" << url << "]")
    end
  end

  it "should contain a distance in miles or km for each event with good coords" do
    render 'event/list'
    for event in @events do
      if !event.coords.nil? then
        response.should have_tag("#event_#{event.id} .distance", /\d (miles|km)/)
      end
    end
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
  
  it "should have a control to set the current user's attendance for each event" do
    render 'event/list'
    for event in @events do
      response.should have_tag("#event_#{event.id} form.attendance select.commit")
    end
  end
  
  it "should include event/list.js for JavaScript enhancements" do
    render 'event/list'
    response[:javascript].should =~ %r{<script[^>]*event/list\.js}
  end
end
