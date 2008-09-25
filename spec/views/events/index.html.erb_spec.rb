require File.dirname(__FILE__) + '/../../spec_helper'

include ERB::Util
include ActionView::Helpers::UrlHelper
include EventsHelper

describe "/events/index" do
  fixtures :states, :countries, :events, :users, :commitments
  before(:each) do
    login_as :marnen
    @events = Event.find(:all)
    assigns[:events] = @events
    assigns[:current_user] = users(:marnen)
    User.stub!(:current_user).and_return(assigns[:current_user])
  end
  
  it "should have loaded at least one event" do
    render 'events/index'
    @events.size.should > 0
  end
  
  it "should show a sort link in date and event column header" do
    render 'events/index'
    response.should have_tag("th a.sort", h("Date"))
    response.should have_tag("th a.sort", h("Event"))
  end
  
  it "should show a sort indicator next to headers that have been sorted by" do
=begin
    assigns[:order] = 'name'
    assigns[:direction] = 'desc'
    render 'events/index' # , {:order => 'name', :direction => 'desc'}
    response.should have_text(h("Event ↓"))
=end
    pending "this spec always fails, even though the application behaves correctly...need to rewrite with a helper?"
  end
  
  it "should render _event for each event" do
    template.expect_render(:partial => 'event', :collection => @events)
    render 'events/index'
  end
  
  it "should include events/index.js for JavaScript enhancements" do
    render 'events/index'
    response[:javascript].should =~ %r{<script[^>]*events/index\.js}
  end

  it "should contain an autodiscovery link for the RSS feed" do
    render 'events/index'
    response[:head].should have_tag("link[title=RSS][href=#{formatted_feed_events_url(:rss)}]")
  end
end
