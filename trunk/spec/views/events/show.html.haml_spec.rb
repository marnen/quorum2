require File.dirname(__FILE__) + '/../../spec_helper'

describe "/events/show" do
  fixtures :events
  
  before(:each) do
    @event = Event.find(:first)
    template.stub!(:current_object).and_return(@event)
  end
  
  it "should render the event and table_header partials" do
    template.should_receive(:render).with(:partial => 'table_header', :locals => {:sortlinks => false})
    template.should_receive(:render).with(:partial => 'event', :locals => {:event => @event})
    render '/events/show'
  end
  
  it "should wrap the whole thing in a <table> of class events" do
    render '/events/show'
    response.should have_text(%r{^\s*<\s*table\s+([^>]*\s*)class=(["'])events\2[^>]*>.*</table>\s*$}m)
  end
end
