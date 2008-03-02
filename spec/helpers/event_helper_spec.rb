require File.dirname(__FILE__) + '/../spec_helper'

describe EventHelper do
  fixtures :users
  
  before(:each) do
    @event = Event.new
  end
  
  # refactor from list.html.erb_spec into here?
  
  it "should generate an iCal unique id as a String" do
    ical_uid(@event).should be_a_kind_of(String)
  end
  
  it "should generate an edit link as a String" do
    edit_link(@event).should be_a_kind_of(String)
  end
  
  it "should generate an iCal export link as a String" do
    ical_link(@event).should be_a_kind_of(String)
  end
  
  it "should generate a map link as a String" do
    map_link(@event).should be_a_kind_of(String)
  end
  
  it "should generate a microformat HTML date element as a String" do
    @event.date = Time.now # arbitrary value
    date_element(@event).should be_a_kind_of(String)
  end
=begin
  #Delete this example and add some real ones or delete this file
  it "should include the EventHelper" do
    included_modules = self.metaclass.send :included_modules
    included_modules.should include(EventHelper)
  end
=end
  it "should generate a comma-separated list of names from an array of users" do
    names = list_names users
    for user in users do
      names.should include user.fullname
    end
  end
  
end
