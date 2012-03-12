# coding: UTF-8

require 'spec_helper'

describe EventsHelper do
  before(:each) do
    @event = FactoryGirl.create :event
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
    users = (1..5).map { FactoryGirl.create :user }
    names = helper.list_names users
    users.each do |user|
      names.should include(user.to_s)
    end
  end

  it "should get an attendance status for an event and a user" do
    helper.attendance_status(@event, FactoryGirl.create(:user)).should == :maybe
  end

  describe '#attendance_comment' do
    let(:user) { Factory :user }

    it 'should retrieve the comment string for the event and user' do
      commitment = Factory :commitment, event: @event, user: user
      helper.attendance_comment(@event, user).should == commitment.comment
    end

    it "should return nil if there's no commitment for the event and user" do
      helper.attendance_comment(@event, user).should be_nil
    end
  end

  it "should generate a distance string from an event to a user's coords," do
    marnen = FactoryGirl.create :user, :coords => Point.from_x_y(5, 10) # TODO: use Faker instead of arbitrary coordinates
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
    link.should have_selector("a.sort[href='#{url_for :controller => 'events', :action => 'index', :order => :date, :direction => :asc}']", :content => "Date")

    #link = sort_link("Date", :date, :desc)
    #link.should match(/\A<a [^>]*href="#{url_for :controller => 'events', :action => 'index', :order => :date, :direction => :desc}".*<\/a>\Z/i)
 end
end

describe EventsHelper, "event_map" do
  before(:each) do
    User.stub!(:current_user).and_return(FactoryGirl.create :user)
  end

  it "should return a safe string" do
    helper.event_map(Factory(:event), DOMAIN).should be_html_safe
  end

  it "should set up a GMap with all the options" do
    event = FactoryGirl.create :event

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

    map = helper.event_map(event, DOMAIN)
    {'#gmap' => nil, '#info' => nil, '#lat' => ERB::Util::h(event.coords.lat), '#lng' => ERB::Util::h(event.coords.lng)}.each do |k, v|
      map.should have_selector(k, :content => v)
    end

    pending "RSpec 2 has broken these lines. Not sure how to fix, but in any case we should change the helper architecture." do
      assigns[:extra_headers].should_not be_nil
      assigns[:extra_headers].should include(gmap_header)
      assigns[:extra_headers].should include(javascript_include_tag 'events/map')
    end
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

describe EventsHelper, "info" do
  before :each do
    User.stub(:current_user).and_return(Factory :user)
    @event = Factory :event
    @info = helper.info(@event)
  end

  it "should return a safe string" do
    @info.should be_html_safe
  end

  it "should display a <h3> with the site name" do
    @info.should have_selector('h3', :content => @event.site)
  end

  it "should display the address separated by line breaks" do
    @info.should include([h(@event.street), h(@event.street2), h([@event.city, @event.state.code, @event.state.country.code].join(', '))].join(tag :br))
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
    m.should have_selector("a[target='markdown']", :content => 'Markdown')
  end
end

describe EventsHelper, "rss_url" do
  it "should return the RSS feed URL for the current user" do
    user = FactoryGirl.create :user
    User.current_user = user
    helper.rss_url.should == feed_events_url(:format => :rss, :key => user.single_access_token)
  end

  it "should return nil if there is no current user" do
    User.current_user = false
    helper.rss_url.should be_nil
    User.current_user = nil
    helper.rss_url.should be_nil
  end
end

describe EventsHelper, '#status_strings' do
  it 'should return an array of status strings' do
    helper.status_strings.should == {yes: 'attending', no: 'not attending', maybe: 'uncommitted'}
  end
end
