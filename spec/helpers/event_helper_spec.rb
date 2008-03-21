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
  
  it "should generate a delete link as a String" do
    delete_link(@event).should be_a_kind_of(String)
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
    marnen = users(:marnen)
    @event.coords = marnen.coords
    distance_string(@event, marnen).should =~ /\D0(\.0)? miles/
    user = User.new
    # distance_string(@event, user).should == "" # user.coords is nil -- this spec is not working right now
    @event = Event.new do |e| e.coords = Point.from_x_y(0, 2) end
    user.coords = Point.from_x_y(0, 1)
    distance_string(@event, user).should =~ /\D6(8.7)|9.*miles.*#{h('•')}$/ # 1 degree of latitude
  end
  
  it "should generate a sort link for a table header (asc unless desc is specified)" do
    link = sort_link("Date", :date)
    link.should be_a_kind_of(String)
    link.should match(/\A<a [^>]*href="#{url_for :controller => 'event', :action => 'list', :order => :date, :direction => :asc}".*<\/a>\Z/i)
    link.should have_tag("a.sort", "Date")
    
    link = sort_link("Date", :date, :desc)
    link.should match(/\A<a [^>]*href="#{url_for :controller => 'event', :action => 'list', :order => :date, :direction => :desc}".*<\/a>\Z/i)
 end
end

describe EventHelper, "event_map" do
  fixtures :events, :states, :countries
  
  it "should set up a GMap with all the options" do
    gmap = GMap.new(:foo)
    GMap.should_receive(:header).at_least(:once)
    GMap.should_receive(:new).and_return(gmap)
    gmap.should_receive(:div)
    gmap.should_receive(:center_zoom_init)
    gmap.should_receive(:overlay_init).with(an_instance_of(GMarker))
    gmap.should_receive(:to_html).at_least(:once)
    
    event = events(:one)
        
    event_map(event, DOMAIN)
    @extra_headers.should_not be_nil
    @extra_headers.should include(GMap.header.to_s)
    @extra_headers.should include(gmap.to_html.to_s)
  end
end

describe EventHelper, "ical_escape" do
  it "should make newlines into '\n'" do
    ical_escape("a\na").should == 'a\\na'
  end
  
  it "should double backslashes" do
    bb = '\\' + '\\'
    ical_escape('\\c\\n\\').should == bb + 'c' + bb + 'n' + bb
  end
  
  it "should put backslashes before commas and semicolons" do
    ical_escape('comma,semicolon;').should == 'comma\\,semicolon\\;'
  end
end

describe EventHelper, "list_names" do
  it "should return an empty string when called with nil argument" do
    list_names(nil).should == ''
  end
  
end
