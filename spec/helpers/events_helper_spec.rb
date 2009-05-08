require File.dirname(__FILE__) + '/../spec_helper'

describe EventsHelper do
  fixtures :users, :states, :countries
  
  before(:each) do
    @event = Event.make
  end
  
  # refactor from list.html.erb_spec into here?
  
  it "should generate an iCal unique id as a String" do
    helper.ical_uid(@event).should be_a_kind_of(String)
  end
  
  it "should generate a delete link as a String" do
    helper.delete_link(@event).should be_a_kind_of(String)
  end
  
  it "should generate an edit link as a String" do
    helper.edit_link(@event).should be_a_kind_of(String)
  end
  
  it "should generate an iCal export link as a String" do
    helper.ical_link(@event).should be_a_kind_of(String)
  end
  
  it "should generate a map link as a String" do
    helper.map_link(@event).should be_a_kind_of(String)
  end
  
  it "should generate a microformat HTML date element as a String" do
    @event.date = Time.now # arbitrary value
    helper.date_element(@event).should be_a_kind_of(String)
  end
=begin
  #Delete this example and add some real ones or delete this file
  it "should include the EventsHelper" do
    included_modules = self.metaclass.send :included_modules
    included_modules.should include(EventsHelper)
  end
=end
  it "should generate a comma-separated list of names from an array of users" do
    names = helper.list_names users
    for user in users do
      names.should include(user.fullname)
    end
  end
  
  it "should get an attendance status for an event and a user" do
    helper.attendance_status(@event, users(:quentin)).should == :maybe
  end
  
  it "should generate a distance string from an event to a user's coords," do
    marnen = users(:marnen)
    @event.coords = marnen.coords
    helper.distance_string(@event, marnen).should =~ /\D\d(\.\d+)? miles/
    user = User.new
    # distance_string(@event, user).should == "" # user.coords is nil -- this spec is not working right now
    @event = Event.new do |e| e.coords = Point.from_x_y(0, 2) end
    user.coords = Point.from_x_y(0, 1)
    helper.distance_string(@event, user).should =~ /\D6(8.7)|9.*miles.*#{h('•')}$/ # 1 degree of latitude
  end
  
  it "should generate a sort link for a table header (asc unless desc is specified)" do
    @request.stub!(:path_parameters).and_return(:controller => 'events', :action => 'index')
    link = helper.sort_link("Date", :date)
    link.should be_a_kind_of(String)
    link.should match(/\A<a [^>]*href="#{url_for :controller => 'events', :action => 'index', :order => :date, :direction => :asc}".*<\/a>\Z/i)
    link.should have_tag("a.sort", "Date")
    
    #link = sort_link("Date", :date, :desc)
    #link.should match(/\A<a [^>]*href="#{url_for :controller => 'events', :action => 'index', :order => :date, :direction => :desc}".*<\/a>\Z/i)
 end
end

describe EventsHelper, "event_map" do
  fixtures :events, :states, :countries, :users, :states, :countries
  
  before(:each) do
    User.stub!(:current_user).and_return(users(:marnen))
  end
  
  it "should set up a GMap with all the options" do
    event = events(:one)

    # TODO: since this code is now in events/map.js , translate these specs into JavaScript!
=begin
    marker = GMarker.new([1.0, 2.0])
    gmap_header = "[Stubbed header for #{DOMAIN}]"
    GMap.should_receive(:header).with(:host => DOMAIN).at_least(:once).and_return(gmap_header)
    GMarker.stub!(:new).and_return(marker)
    gmap.should_receive(:center_zoom_init)
    gmap.should_receive(:overlay_init).with(marker)
    marker.should_receive(:open_info_window).with(EventsHelper::ElementVar.new(helper.info(event)))
    gmap.should_receive(:control_init) do |opts|
      opts.should be_a_kind_of(Hash)
      opts.should have_key(:large_map)
      opts[:large_map].should == true
      opts.should have_key(:map_type)
      opts[:map_type].should == true
    end
    gmap.should_receive(:to_html).at_least(:once)
=end
    
    gmap_header = "[Stubbed header for #{DOMAIN}]"
    GMap.should_receive(:header).with(:host => DOMAIN).at_least(:once).and_return(gmap_header)
    gmap = GMap.new(:gmap)
    gmap_div = '<div id="gmap">GMap div</div>'
    gmap.should_receive(:div).and_return(gmap_div)
    GMap.should_receive(:new).and_return(gmap)
    info_div = '<div id="info">Event info</div>'
    helper.should_receive(:info).with(event).at_least(:once).and_return(info_div)
    
    map = helper.event_map(event, DOMAIN)
    {'#gmap' => nil, '#info' => nil, '#lat' => ERB::Util::h(event.coords.lat), '#lng' => ERB::Util::h(event.coords.lng)}.each do |k, v|
      map.should have_tag(k, v)
    end
    assigns[:extra_headers].should_not be_nil
    assigns[:extra_headers].should include(gmap_header)
    assigns[:extra_headers].should include(javascript_include_tag 'events/map')
  end
end

describe EventsHelper, "ical_escape" do
  it "should make newlines into '\n'" do
    helper.ical_escape("a\na").should == 'a\\na'
  end
  
  it "should double backslashes" do
    bb = '\\' + '\\'
    helper.ical_escape('\\c\\n\\').should == bb + 'c' + bb + 'n' + bb
  end
  
  it "should put backslashes before commas and semicolons" do
    helper.ical_escape('comma,semicolon;').should == 'comma\\,semicolon\\;'
  end
end

describe EventsHelper, "list_names" do
  it "should return an empty string when called with nil argument" do
    helper.list_names(nil).should == ''
  end
end

describe EventsHelper, "markdown_hint" do
  it "should return a span of class 'hint' with a link to Markdown in it" do
    m = helper.markdown_hint
    m.should match(%r{^<span class=(['"])hint\1[^>]*>.*</span>$})
    m.should have_tag('a[target="markdown"]', 'Markdown')
  end
end

describe EventsHelper, "rss_url" do
  fixtures :users
  
  it "should return the RSS feed URL for the current user" do
    User.current_user = users(:marnen)
    helper.rss_url.should == formatted_feed_events_url(:format => :rss, :key => users(:marnen).feed_key)
  end
  
  it "should return nil if there is no current user" do
    User.current_user = false
    helper.rss_url.should be_nil
    User.current_user = nil
    helper.rss_url.should be_nil
  end
end
