require 'spec_helper'

describe EventsController, "index" do
  before(:each) do
    UserSession.create User.make
  end
  
  it "should be successful" do
    get :index
    response.should be_success
  end
 
  it "should set the page_title" do
    get :index
    assigns[:page_title].should_not be_nil
  end
  
  it "should get all non-deleted events, with distance, ordered by date, earliest to latest" do
    Event.should_receive(:find) do |arg1, opts|
      arg1.should == :all
      opts.should be_a_kind_of(Hash)
      opts[:order].should == 'date asc'
    end.once
    get :index
  end
  
  it "should pass sorting parameters from the URL" do
    order = 'name'
    direction = 'desc'
    params = {:order => order, :direction => direction}
    route_for(params.merge(:controller => 'events', :action => 'index')).should == "/events/index/#{order}/#{direction}"
    Event.should_receive(:find) do |arg1, arg2|
      arg1.should == :all
      arg2.should be_an_instance_of(Hash)
      arg2.should have_key(:order)
      arg2[:order].should == "#{order} #{direction}"
      arg2.should have_key(:conditions)
      conditions = arg2[:conditions]
      conditions.should be_an_instance_of(Array)
      conditions[0].should =~ /date >= :from_date/i
      conditions[1].should be_an_instance_of(Hash)
      conditions[1].should have_key(:from_date)
      conditions[1][:from_date].should be_an_instance_of(Date)
      conditions[1][:from_date].should == Time.zone.today # default value if not set in params
      conditions[1].should have_key(:to_date)
      conditions[1][:to_date].should be_nil
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
    user = User.make
    User.stub!(:current_user).and_return(user) # we need this for some of the callbacks on Calendar and Event
    @calendar = Calendar.make
    @one = Event.make(:name => 'Event 1', :calendar => @calendar, :date => Date.civil(2008, 7, 4), :description => 'The first event.', :created_at => 1.week.ago)
    @two = Event.make(:name => 'Event 2', :calendar => @calendar, :date => Date.civil(2008, 10, 10), :description => 'The <i>second</i> event.', :created_at => 2.days.ago)
    @events = [@one, @two]
    controller.stub!(:current_objects).and_return(@events)
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
    params[:key].should_not be_nil
    assigns[:key].should == params[:key]
  end
  
  it "should set params[:feed_user] to the user whom the key belongs to" do
    params[:feed_user].should == User.find_by_single_access_token(params[:key])
  end
  
  it "should have an <atom:link rel='self'> tag" do
    css_select('rss').each do |rss|
      @m = css_select(rss, 'channel')[0].to_s[%r{<\s*atom:link(\s*[^>]*)?>}]
    end
    @m.should_not be_blank
    @m.should =~ /href=(["'])#{feed_events_url(:rss, params[:key])}\1/
    @m.should =~ /rel=(["'])self\1/
  end
  
  it "should have an appropriate <title> tag" do
    response.should have_tag('channel > title', %r{#{SITE_TITLE}})
  end
  
  it "should link to the event list" do
    response.should have_tag('channel > link', events_url)
  end
  
  it "should contain a <description> element, including (among other things) the name of the user whose feed it is" do
    response.should have_tag('channel > description', %r{#{ERB::Util::html_escape params[:feed_user]}})
  end
    
  it "should contain an entry for every event, with <title>, <description> (with address and description), <link>, <guid>, and <pubDate> elements" do
    @events.each do |e|
      response.should have_tag('item title',ERB::Util::html_escape(e.name)) # actually, this is XML escape, but close enough
      response.should have_tag('item description', /#{ERB::Util::html_escape(e.date.to_s(:rfc822))}.*#{ERB::Util::html_escape(e.address.to_s(:geo))}.*#{ERB::Util::html_escape(RDiscount.new(ERB::Util::html_escape(e.description)).to_html)}/m) # kinky but accurate
      response.should have_tag('item link', event_url(e))
      response.should have_tag('item guid', event_url(e))
      response.should have_tag('item pubDate', e.created_at.to_s(:rfc822))
    end
  end
end

describe EventsController, "feed.rss (login)" do
  render_views
  
  it "should not list any events if given an invalid single_access_token" do
    User.stub!(:find_by_single_access_token).and_return(nil)
    get :feed, :fmt => 'rss', :key => 'fake key'
    Event.should_not_receive(:find)
    response.should_not have_tag('item')
  end
  
  it "should list events if given a valid single_access_token" do
    @user = User.make
    UserSession.create @user
    calendar = Calendar.make # @user will be subscribed to
    @events = (1..5).map{Event.make(:calendar => calendar)}
    User.stub!(:find_by_single_access_token).and_return(@user)
    Event.should_receive(:find).and_return(@events)
    get :feed, :format => 'rss', :key => @user.single_access_token
    response.should have_tag('item')
  end
end

describe EventsController, 'index.pdf' do
  before(:each) do
    UserSession.create User.make
    controller.stub!(:current_objects).and_return([mock_model(Event, :null_object => true)])
  end
  
  it "should be successful" do
    get :index, :format => 'pdf'
    response.should be_success
  end
  
  it "should return the appropriate MIME type for a PDF file" do
    get :index, :format => 'pdf'
    response.content_type.should =~ %r{^application/pdf}
  end
  
  it "should set assigns[:users]" do
    @perms = [mock_model(Permission)]
    @perms.should_receive(:find_all_by_show_in_report).with(true, :include => :user).and_return(@perms)
    @perms[0].should_receive(:user).and_return(mock_model(User))
    @event = mock_model(Event, :calendar => mock_model(Calendar, :permissions => @perms))
    controller.current_objects.should_receive(:[]).and_return(@event)
    get :index, :format => 'pdf'
    assigns[:users].should_not be_nil
  end
end

describe EventsController, "change_status" do
  before(:each) do
    @user = User.make
    UserSession.create @user
  end
  
  it "should change attendance status for current user if called with a non-nil event id" do
    event = Event.make
    commitment = Commitment.make(:user => @user, :event => event, :status => true)
    id = event.id
    status = :yes # could also be :no or :maybe
    Event.should_receive(:find_by_id).with(id.to_s).once.and_return(event)
    event.commitments.should_receive(:find_or_create_by_user_id).with(@user.id).once.and_return(commitment)
    commitment.should_receive(:status=).with(true).once.and_return(true)
    commitment.should_receive(:save!).once.and_return(true)
    get "change_status", :id => id, :status => status
  end
  
  it "should redirect to index on a standard request" do
    get 'change_status'
    response.should redirect_to(:action => :index)
  end
  
  it "should render an event row on an Ajax request" do
    event = Event.make
    request.stub!(:xhr?).and_return(true)
    get "change_status", :id => event.id, :status => 'yes' # status could also be :no or :maybe
    response.should render_template('_event') # with :locals => {:event => event}, but I can't figure out how to test for that
  end
end

describe EventsController, "new" do
  before(:each) do
    @session = UserSession.create User.make
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
    response.should_not redirect_to(:action => :list)

    my_event = Event.new #invalid
    post :create, :event => my_event.attributes
    response.should_not redirect_to(:action => :list)
    
    my_event = Event.new(:name => 'name', :state_id => 23, :calendar_id => 'foo') # minimal valid set of attributes
    post :create, :event => my_event.attributes
    response.should redirect_to(:action => :index)
    flash[:notice].should_not be_nil
  end
  
end

describe EventsController, "create" do
  before(:each) do
    UserSession.create User.make
  end
  
  it "should save an Event object" do
    my_event = Event.new(:name => 'name', :state_id => 23)
    my_event.should_not be_nil
    my_event.created_by_id.should be_nil
    Event.stub!(:new).and_return(my_event)
    my_event.should_receive(:save)
    post :create, :event => my_event.attributes
    # assigns[:event].name.should == my_event.name
    # assigns[:event].id.should_not be_nil
    # assigns[:event].created_by_id.should == User.current_user.id
  end
end

describe EventsController, "edit" do
  before(:each) do
    @event = Event.make
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
    response.should_not redirect_to(:action => :index)
  end
  
  it "should redirect to list with an error if the event does not exist" do
    get 'edit', :id => 0 # nonexistent
    flash[:error].should_not be_nil
    response.should redirect_to(:action => :index)
  end
  
  it "should reuse the new-event form" do
    get 'edit', :id => @event.id
    response.should render_template(:new)
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
    event = Event.find(:first)
    id = event.id
    event.should be_valid
    post 'update', :event => event.attributes, :id => id # valid
    request.should be_post
    assigns[:current_object].should_receive(:update_attributes)
    response.should redirect_to(:action => :index)
    flash[:notice].should_not be_nil
    
    event.name = nil # now it's invalid
    post 'update', :event => event.attributes, :id => id
    response.should_not redirect_to(:action => :index)
  end
  
  it "should reset coords to nil when saving" do
    event = Event.find(:first)
    id = event.id.to_s
    event.coords.should_not be_nil
=begin
    Event.should_receive(:find).with(id).twice.and_return(event, Event.find_by_id(id))
    event.should_receive(:update_attributes).with(an_instance_of(Hash)).once
=end
    post 'edit', :event => event.attributes, :id => id
    event = Event.find(id)
    event.should_receive(:coords_from_string).once # calling event.coords should trigger recoding
    event.coords
  end
end

describe EventsController, "show" do
  before(:each) do
    UserSession.create User.make
  end
  
  it "should set the page title" do
    @event = Event.make
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
    @calendar = Calendar.make
    @event = Event.make(:calendar => @calendar)
    @id = @event.id
  end
  
  it "should not work from non-admin account" do
    UserSession.create User.make
    @event.should_not_receive(:hide)
    post 'delete', :id => @id
    flash[:error].should_not be_nil
  end
  
  it "should work from admin account" do
    UserSession.create admin_user(@event.calendar)
    Event.should_receive(:find).with(@id.to_i).and_return(@event)
    @event.should_receive(:hide)
    post 'delete', :id => @id
    User.current_user.permissions.find_by_calendar_id(@event.calendar_id).role.name.should == 'admin'
    flash[:error].should be_nil
  end
end

describe EventsController, "map" do
  before(:each) do
    UserSession.create User.make
    @one = Event.make
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
    user = User.make
    UserSession.create user
    @my_event = Event.make
    Event.should_receive(:find).with(@my_event.id.to_i).and_return(@my_event)
  end
  
  it "should use the ical view" do
    get :export, :id => @my_event.id
    response.should render_template('events/ical.ics.erb')
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
  User.make do |user|
    user.permissions.destroy_all
    user.permissions.make(:admin, :calendar => calendar)
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