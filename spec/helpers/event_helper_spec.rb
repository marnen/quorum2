require File.dirname(__FILE__) + '/../spec_helper'

describe EventHelper do
  fixtures :users, :states, :countries
  
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
      names.should include(user.fullname)
    end
  end
  
  it "should generate a <td> with attendance controls for the supplied event and the current user" do
    att = attendance_control(@event, users(:quentin))
    att.should be_a_kind_of(String)
    att.should match(/^<td.*<\/td>$/mi)
    att.should have_tag("select.commit")
  end
  
  it "should generate a distance string from an event to a user's coords," do
    @event.state = states(:ny) # required anyway, and makes testing easier
    @event.coords = nil
    marnen = users(:marnen)
    @event.coords = marnen.coords
    distance_string(@event, marnen).should =~ /\D0(\.0)? miles/
    user = User.new
    # distance_string(@event, user).should == "" # user.coords is nil -- this spec is not working right now
    @event.coords = Point.from_x_y(0, 2)
    user.coords = Point.from_x_y(0, 1)
    distance_string(@event, user).should =~ /\D6(8.7)|9.*miles.*#{h('•')}$/ # 1 degree of latitude
 end
  
end

describe EventHelper, "list_names" do
  it "should return an empty string when called with nil argument" do
    list_names(nil).should == ''
  end
  
end
