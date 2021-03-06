# coding: UTF-8

require 'spec_helper'

describe EventsController, "index" do
  before(:each) do
    UserSession.create FactoryGirl.create(:user)
  end

  it "should pass sorting parameters from the URL" do
    order = 'name'
    direction = 'desc'
    params = {:order => order, :direction => direction}
    begin
      {:get => "/events/index/#{order}/#{direction}"}.should route_to params.merge(:controller => 'events', :action => 'index')
    rescue NoMethodError
      warn "route_to is currently problematic: see https://github.com/rspec/rspec-rails/issues/1262"
    end
    mock_conditions = mock 'conditions'
    mock_conditions.should_receive(:order).with "#{order} #{direction}"
    mock_includes = mock 'includes'
    Event.should_receive(:includes).and_return(mock_includes)
    mock_includes.should_receive(:where) do |conditions|
      conditions.should be_an_instance_of(Array)
      conditions[0].should =~ /date >= :from_date/i
      conditions[1].should be_an_instance_of(Hash)
      conditions[1].should have_key(:from_date)
      conditions[1][:from_date].should be_an_instance_of(Date)
      conditions[1][:from_date].should == Time.zone.today # default value if not set in params
      conditions[1].should have_key(:to_date)
      conditions[1][:to_date].should be_nil
      mock_conditions
    end
    get :index, params
=begin
  TODO: when we have a search form, I suppose :)

  If to_date is not nil, then we need the following specs for the monstrosity above:
  conditions[0].should =~ /between :from_date and :to_date/i
  conditions[1][:to_date].should be_an_instance_of(Date)
  conditions[1][:to_date].should > Time.zone.today + 99.years
=end
  end

  it "should have date/asc as default order and direction in URL" do
    pending "route_for doesn't actually seem to work this way" do
      route_for(:controller => 'events', :action => 'index', :order => 'date', :direction => 'asc').should == 'foo' # '/events/index'
    end
  end

  it "should pass sorting parameters on to the view" do
    get :index
    assigns[:order].should_not be_nil
    assigns[:direction].should_not be_nil
  end
end

describe EventsController, "feed.rss" do
  render_views

  before(:each) do
    user = FactoryGirl.create :user
    User.stub!(:current_user).and_return(user) # we need this for some of the callbacks on Calendar and Event
    @calendar = FactoryGirl.create :calendar
    FactoryGirl.create :permission, user: user, calendar: @calendar, role: FactoryGirl.create(:role)
    @one = FactoryGirl.create :event, :name => 'Event 1', :calendar => @calendar, :date => Date.civil(2008, 7, 4), :description => 'The first event.', :created_at => 1.week.ago
    @two = FactoryGirl.create :event, :name => 'Event 2', :calendar => @calendar, :date => Date.civil(2008, 10, 10), :description => 'The <i>second</i> event.', :created_at => 2.days.ago
    @events = [@one, @two]
    get :feed, :format => 'rss', :key => user.single_access_token
  end

  it "should be successful" do
    response.should be_success
  end

  it "should set a MIME type of application/rss+xml" do
    response.content_type.should =~ (%r{^application/rss\+xml})
  end

  it "should set RSS version 2.0 and declare the Atom namespace" do
    m = response.body[%r{<\s*rss(\s*[^>]*)?>}]
    m.should_not be_blank
    m.should =~ /version=(["'])2.0\1/
    m.should =~ %r{xmlns:\w+=(["'])http://www.w3.org/2005/Atom\1}
  end

  it "should set @key to params[:key]" do
    controller.params[:key].should_not be_nil
    assigns[:key].should == controller.params[:key]
  end

  it "should set params[:feed_user] to the user whom the key belongs to" do
    controller.params[:feed_user].should == User.find_by_single_access_token(controller.params[:key])
  end

  it "should have an <atom:link rel='self'> tag" do
    css_select('rss').each do |rss|
      @m = css_select(rss, 'channel')[0].to_s[%r{<\s*atom:link(\s*[^>]*)?>}]
    end
    @m.should_not be_blank
    @m.should =~ /href=(["'])#{feed_events_url(:rss, controller.params[:key])}\1/
    @m.should =~ /rel=(["'])self\1/
  end

  it "should have an appropriate <title> tag" do
    response.body.should have_selector('channel > title', :content => %r{#{SITE_TITLE}})
  end

  it "should link to the event list" do
    response.body.should have_selector('channel > link', :content => events_url)
  end

  it "should contain a <description> element, including (among other things) the name of the user whose feed it is" do
    response.body.should have_selector('channel > description', :content => %r{#{ERB::Util::html_escape controller.params[:feed_user]}})
  end

  it "should contain an entry for every event, with <title>, <description> (with address and description), <link>, <guid>, and <pubDate> elements" do
    @events.each do |e|
      response.body.should have_selector('item title', :content => ERB::Util::html_escape(e.name)) # actually, this is XML escape, but close enough
      response.body.should have_selector('item description', :content => /#{ERB::Util::html_escape(e.date.to_s(:rfc822))}.*#{ERB::Util::html_escape(e.address.to_s(:geo))}.*#{ERB::Util::html_escape(RDiscount.new(ERB::Util::html_escape(e.description)).to_html)}/m) # kinky but accurate
      response.body.should have_selector('item link', :content => event_url(e))
      response.body.should have_selector('item guid', :content => event_url(e))
      pending "Capybara doesn't handle capital letters in selectors properly" do
        response.body.should have_selector('item pubDate', :content => e.created_at.to_s(:rfc822))
      end
    end
  end
end

describe EventsController, "feed.rss (login)" do
  render_views

  it "should not list any events if given an invalid single_access_token" do
    User.stub!(:find_by_single_access_token).and_return(nil)
    get :feed, :format => 'rss', :key => 'fake key'
    Event.should_not_receive(:find)
    response.should_not have_selector('item')
  end

  it "should list events if given a valid single_access_token" do
    @user = FactoryGirl.create :user
    UserSession.create @user
    calendar = FactoryGirl.create :calendar
    FactoryGirl.create :permission, user: @user, calendar: calendar
    @events = (1..5).map { FactoryGirl.create :event, :calendar => calendar }
    User.stub!(:find_by_single_access_token).and_return(@user)
    @events.stub!(:order).and_return @events
    mock_includes = mock 'includes'
    mock_includes.should_receive(:where).and_return(@events)
    Event.should_receive(:includes).and_return mock_includes
    get :feed, :format => 'rss', :key => @user.single_access_token
    response.body.should have_selector('item')
  end
end

describe EventsController, 'index.pdf' do
  before(:each) do
    @user = FactoryGirl.create :user
    UserSession.create @user
    User.stub(:current_user).and_return @user
    request.env["SERVER_PROTOCOL"] = "http" # see http://iain.nl/prawn-and-controller-tests
  end

  context 'generic events' do
    before :each do
      event = FactoryGirl.create :event
      FactoryGirl.create :permission, :calendar => event.calendar, :user => @user
      controller.stub!(:current_objects).and_return([event])
    end

    it "should be successful" do
      get :index, :format => 'pdf'
      response.should be_success
    end

    it "should return the appropriate MIME type for a PDF file" do
      get :index, :format => 'pdf'
      response.content_type.should =~ %r{^application/pdf}
    end
  end

  it "should set assigns[:users]" do
    @perms = [FactoryGirl.create(:permission, :user => @user)]
    @event = FactoryGirl.create :event, :calendar => FactoryGirl.create(:calendar, :permissions => @perms)
    controller.stub(:current_objects).and_return([@event])
    get :index, :format => 'pdf'
    assigns[:users].should_not be_nil
  end
end

describe EventsController, "change_status" do
  before(:each) do
    @user = FactoryGirl.create :user
    UserSession.create @user
  end

  it "should change attendance status for current user if called with a non-nil event id" do
    event = FactoryGirl.create :event
    id = event.id.to_s
    status = :yes # could also be :no or :maybe
    Event.should_receive(:find_by_id).with(id).once.and_return(event)
    event.should_receive(:change_status!).with(@user, true, nil)
    get "change_status", :id => id, :status => status
  end

  it "should redirect to index on a standard request" do
    get 'change_status'
    response.should redirect_to(:action => :index)
  end

  it "should render an event row on an Ajax request" do
    event = FactoryGirl.create :event
    xhr :get, "change_status", :id => event.id, :status => 'yes' # status could also be :no or :maybe
    response.should render_template('_event') # with :locals => {:event => event}, but I can't figure out how to test for that
  end
end

describe EventsController, "new" do
  before(:each) do
    @session = UserSession.create FactoryGirl.create(:user)
  end

  it "should require login" do
    get :new
    response.should be_success
    @session.destroy
    get :new
    response.body.should be_blank # not sure why this works and nothing else does...
  end

  it "should be successful if logged in" do
   get :new
   response.should be_success
  end

  it "should set the page_title" do
    get 'new'
    assigns[:page_title].should_not be_nil
  end

  it "should create an Event object" do
    e = Event.new
    Event.should_receive(:new).and_return(e)
    get 'new'
    assigns[:event].should_not be_nil
  end

  it "should redirect to event list with flash after post with successful save, but not otherwise" do
    get 'new'
    response.should_not be_redirect

    my_event = FactoryGirl.build :event, name: nil, calendar: nil, state: nil # invalid
    post :create, :event => my_event.attributes
    response.should_not be_redirect

    my_event = FactoryGirl.build :event
    post :create, :event => my_event.attributes
    response.should redirect_to(:action => :index)
    flash[:notice].should_not be_nil
  end
end

describe EventsController, "create" do
  let(:user) { FactoryGirl.create :user }

  before(:each) do
    UserSession.create user
  end

  it "should save an Event object" do
    event = FactoryGirl.build :event, created_by: nil
    post :create, event: event.attributes
    Event.find_by_name(event.name).created_by.should == user
  end
end

describe EventsController, "edit" do
  before(:each) do
    @event = FactoryGirl.create :event
    @admin = admin_user(@event.calendar)
    UserSession.create @admin
  end

  it "should redirect to list with an error if the user does not own the event and is not an admin" do
    @event.should_receive(:allow?).with(:edit).and_return(false)
    Event.should_receive(:find).and_return(@event)
    get 'edit', :id => @event.id
    flash[:error].should_not be_nil
    response.should redirect_to(:action => :index)
  end

  it 'should allow editing if the user is authorized to edit the event' do
    @event.should_receive(:allow?).with(:edit).and_return(true)
    Event.should_receive(:find).and_return(@event)
    get 'edit', :id => @event.id
    flash[:error].should be_nil
    response.should_not be_redirect
  end

  it "should redirect to list with an error if the event does not exist" do
    get 'edit', :id => 0 # nonexistent
    flash[:error].should_not be_nil
    response.should redirect_to(:action => :index)
  end

  it "should set the page title" do
    get 'edit', :id => @event.id
    assigns[:page_title].should_not be_nil
  end

  it "should set the event" do
    get 'edit', :id => @event.id
    assigns[:event].should == @event
  end

=begin
  it "should redirect to list with a flash error if no event id is supplied or if id is invalid" do
    get 'edit', :id => 'a' # invalid
    response.should redirect_to(:action => :index)
    flash[:error].should_not be_nil

    get 'edit', :id => nil # no id
    response.should redirect_to(:action => :index)
    flash[:error].should_not be_nil
  end
=end

  it "should redirect to event list with flash after post with successful save, but not otherwise" do
    event = Event.first
    id = event.id
    event.should be_valid
    post 'update', :event => event.attributes, :id => id # valid
    request.should be_post
    response.should redirect_to(:action => :index)
    flash[:notice].should_not be_nil

    event.name = nil # now it's invalid
    post 'update', :event => event.attributes, :id => id
    response.should_not be_redirect
  end
end

describe EventsController, "show" do
  before(:each) do
    UserSession.create FactoryGirl.create(:user)
  end

  it "should set the page title" do
    @event = FactoryGirl.create :event
    @event.should_receive(:allow?).with(:show).at_least(:once).and_return(true)
    Event.should_receive(:find).at_least(:once).and_return(@event)
    get :show, :id => @event.id
    assigns[:page_title].should_not be_nil
    assigns[:page_title].should =~ Regexp.new(@event.name)
  end

  it "should not show an event on a calendar for which the current user doesn't have access" do
    @event = mock_model(Event, :id => 4, :calendar_id => 57, :name => 'Event on another calendar')
    @event.should_receive(:allow?).with(:show).at_least(:once).and_return(false)
    Event.should_receive(:find).at_least(:once).and_return(@event)
     get :show, :id => @event.id
    flash[:error].should_not be_nil
    response.should be_redirect
  end
end

describe EventsController, "delete" do
  before(:each) do
    @calendar = FactoryGirl.create :calendar
    @event = FactoryGirl.create :event, :calendar => @calendar
    @id = @event.id
  end

  it "should not work from non-admin account" do
    UserSession.create FactoryGirl.create(:user)
    @event.should_not_receive(:hide)
    post 'delete', :id => @id
    flash[:error].should_not be_nil
  end

  it "should work from admin account" do
    UserSession.create admin_user(@event.calendar)
    Event.should_receive(:find).with(@id.to_s).and_return(@event)
    @event.should_receive(:hide)
    post 'delete', :id => @id
    User.current_user.permissions.find_by_calendar_id(@event.calendar_id).role.name.should == 'admin'
    flash[:error].should be_nil
  end
end

describe EventsController, "map" do
  before(:each) do
    UserSession.create FactoryGirl.create(:user)
    @one = FactoryGirl.create :event
  end

  it "should use the map view" do
    get :map, :id => @one.id
    response.should render_template(:map)
  end

  it "should get an event" do
    id = @one.id
    get :map, :id => id
    assigns[:event].should == @one
  end

  it "should set the page title" do
    get :map, :id => @one.id
    assigns[:page_title].should_not be_nil
  end

  it "should set the hostname" do
    get :map, :id => @one.id
    assigns[:host].should_not be_nil
  end

=begin
  it "should center the map on the event and add a marker and basic and scale controls" do
    @mock = GMap.new(:map)
    GMap.should_receive(:new).with(:map).and_return(@mock)
    @mock.should_receive(:center_zoom_init).with(an_instance_of(Array), an_instance_of(Fixnum))
    @mock.should_receive(:control_init) do |arg|
      arg.should be_a_kind_of(Hash)
      arg[:large_map].should == true
      arg[:scale].should == true
    end
    @mock.should_receive(:overlay_init).with(an_instance_of(GMarker))
    get :map, :id => @one.id
    response.should render_template(:_)
  end
=end
end

describe EventsController, "export" do
  before(:each) do
    user = FactoryGirl.create :user
    UserSession.create user
    @my_event = FactoryGirl.create :event
    Event.should_receive(:find).with(@my_event.id.to_i).and_return(@my_event)
  end

  it "should use the ical view" do
    get :export, :id => @my_event.id
    response.should render_template('events/ical')
  end

  it "should get an event" do
    get :export, :id => @my_event.id
    assigns[:event].should == @my_event
  end

  it "should set a MIME type of text/calendar" do
    get :export, :id => @my_event.id
    response.content_type.should =~ (%r{^text/calendar})
  end
end

# Returns a User with admin permissions on the specified Calendar.
def admin_user(calendar)
  admin = Role.find_or_create_by(name: 'admin')
  FactoryGirl.create(:user).tap do |u|
    u.permissions.destroy_all
    u.permissions << FactoryGirl.create(:permission, :calendar => calendar, :user => u, :role => admin)
  end
end

=begin
  #Delete these examples and add some real ones
  it "should use EventsController" do
    controller.should be_an_instance_of(EventsController)
  end


  describe "GET 'list'" do
    it "should be successful" do
      get 'list'
      response.should be_success
    end
  end

  describe "GET 'new'" do
    it "should be successful" do
      get 'new'
      response.should be_success
    end
  end

  describe "GET 'edit'" do
    it "should be successful" do
      get 'edit'
      response.should be_success
    end
  end
=end