require File.dirname(__FILE__) + '/../../spec_helper'

include ERB::Util
include ActionView::Helpers::UrlHelper
include EventsHelper

describe 'events/_attendance' do
  fixtures :events, :countries, :states, :commitments, :users

  before(:all) do
    @event_orig = Event.find(:first).clone
  end
  
  before(:each) do
    render :partial => 'events/attendance', :locals => {:event => @event_orig}
  end
  
  it "should have a select element for event" do
    response.should have_tag("select.commit")
  end
  
  it "should have an empty element for the progress indicator" do
    response.should have_tag(".progress", /&nbsp;/)
  end
end