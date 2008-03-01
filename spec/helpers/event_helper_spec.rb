require File.dirname(__FILE__) + '/../spec_helper'

describe EventHelper do
  it "should generate an iCal unique id as a String" do
    event = Event.new
    ical_uid(event).should_not be_nil
    ical_uid(event).should be_a_kind_of(String)
  end
=begin
  #Delete this example and add some real ones or delete this file
  it "should include the EventHelper" do
    included_modules = self.metaclass.send :included_modules
    included_modules.should include(EventHelper)
  end
=end
  
end
