# coding: UTF-8

require 'spec_helper'

include ERB::Util
include ActionView::Helpers::UrlHelper
include EventsHelper

describe 'events/_event' do
  before(:each) do
    Role.destroy_all(:name => 'admin')
    User.destroy_all # TODO: why is this necessary?
    @event = FactoryGirl.create :event
    @user = FactoryGirl.create :user
    [User, view].each {|x| x.stub!(:current_user).and_return @user }
  end

  it "should show an iCal export link for the event, of class 'ical'" do
    render_view
    url = url_for(:controller => 'events', :action => 'export', :id => @event.id, :escape => false)
    rendered.should have_selector("#event_#{@event.id} a.ical[href='#{url}']")
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