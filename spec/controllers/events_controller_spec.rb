require File.dirname(__FILE__) + '/../spec_helper'

describe EventsController, "index" do
  fixtures :users
  
  before(:each) do
    login_as(:quentin)
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
    Event.should_receive(:find).with(:all, :order => 'date asc', :conditions => 'deleted is distinct from true').once
    get :index
  end
  
  it "should pass sorting parameters from the URL" do
    order = 'name'
    direction = 'desc'
    route_for(:controller => 'events', :action => 'index', :order => order, :direction => direction).should == "/events/index/#{order}/#{direction}"
    Event.should_receive(:find) do |arg1, arg2|
      arg1.should == :all
      arg2.should be_an_instance_of(Hash)
      arg2.should include(:order)
      arg2[:order].should == "#{order} #{direction}"
    end
    get :index, :order => order, :direction => direction
  end
  
  it "should have date/asc as default order and direction in URL" do
    route_for(:controller => 'events', :action => 'index', :order => 'date', :direction => 'asc').should == '/events/index'
  end
  
  it "should pass sorting parameters on to the view" do
    get :index
    assigns[:order].should_not be_nil
    assigns[:direction].should_not be_nil
  end
end

describe EventsController, "feed.rss" do
  fixtures :events, :users
  integrate_views
  
  before(:each) do
    get :feed, :format => 'rss', :key => User.find(:first).feed_key
  end
  
  it "should be successful" do
    response.should be_success
  end
  
  it "should set a MIME type of application/rss+xml" do
    response.headers['type'].should =~ (%r{^application/rss\+xml})
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
  
  it "should have an <atom:link rel='self'> tag" do
    css_select('rss').each do |rss|
      @m = css_select(rss, 'channel')[0].to_s[%r{<\s*atom:link(\s*[^>]*)?>}]
    end
    @m.should_not be_blank
    @m.should =~ /href=(["'])#{formatted_feed_events_url(:rss)}\1/
    @m.should =~ /rel=(["'])self\1/
  end
  
  it "should have an appropriate <title> tag" do
    response.should have_tag('title', %r{#{SITE_TITLE}})
  end
  
  it "should link to the event list" do
    response.should have_tag('link', events_url)
  end
  
  it "should contain a description element" do
    response.should have_tag('description')
  end
    
  it "should contain an entry for every event" do
    Event.find(:all).each do |e|
      response.should have_tag('item title',ERB::Util::html_escape(e.name)) # actually, this is XML escape, but close enough
      response.should have_tag('item link', event_url(e))
      response.should have_tag('item guid', event_url(e))
    end
  end
end

describe EventsController, "feed.rss (login)" do
  integrate_views
  fixtures :events
  
  it "should not list any events if given an invalid feed_key" do
    User.stub!(:find_by_feed_key).and_return(nil)
    get :feed, :format => 'rss', :key => 'fake key'
    response.should_not have_tag('item')
  end
  
  it "should list events if given a valid feed_key" do
    @user = mock_model(User, :feed_key => 'foo')
    User.stub!(:find_by_feed_key).and_return(@user)
    get :feed, :format => 'rss', :key => @user.feed_key
    response.should have_tag('item')
  end
end

describe EventsController, "change_status" do
  fixtures :users, :events, :commitments
  
  before(:each) do
    login_as :quentin
  end
  
  it "should change attendance status for current user if called with a non-nil event id" do
    event = events(:one)
    commitment = commitments(:one)
    id = event.id
    status = :yes # could also be :no or :maybe
    Event.should_receive(:find_by_id).with(id.to_s).once.and_return(event)
    event.commitments.should_receive(:find_or_create_by_user_id).with(users(:quentin).id).once.and_return(commitment)
    commitment.should_receive(:status=).with(true).once.and_return(true)
    commitment.should_receive(:save!).once.and_return(true)
    get "change_status", :id => id, :status => status
  end
  
  it "should redirect to index on a standard request" do
    get 'change_status'
    response.should redirect_to(:action => :index)
  end
  
  it "should render an event row on an Ajax request" do
    event = events(:one)
    request.stub!(:xhr?).and_return(true)
    get "change_status", :id => event.id, :status => :yes # status could also be :no or :maybe
    response.should render_template('_event') # with :locals => {:event => event}, but I can't figure out how to test for that
  end
end

describe EventsController, "new" do
  fixtures :users, :states, :countries, :commitments
  
  before(:each) do
    login_as :quentin
  end
  
  it "should require login" do
    pending "need to figure out how to write this"
  end
  
  it "should be successful" do
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
    
    my_event = Event.new(:name => 'name', :state_id => 23) #valid
    post :create, :event => my_event.attributes
    response.should redirect_to(:action => :index)
    flash[:notice].should_not be_nil
  end
  
end

describe EventsController, "create" do
  fixtures :users, :states, :countries, :commitments
  
  before(:each) do
    login_as :quentin
  end
  
  it "should save an Event object" do
    my_event = Event.new(:name => 'name', :state_id => 23)
    my_event.should_not be_nil
    my_event.created_by_id.should be_nil
    Event.stub!(:new).and_return(my_event)
    User.current_user.stub!(:id).and_return(3) # arbitrary value
    my_event.should_receive(:save)
    post :create, :event => my_event.attributes
    # assigns[:event].name.should == my_event.name
    # assigns[:event].id.should_not be_nil
    # assigns[:event].created_by_id.should == User.current_user.id
  end
end

describe EventsController, "edit" do
  fixtures :users, :events
  
  before(:each) do
    login_as :marnen # admin
  end
  
  it "should redirect to list with an error if the user does not own the event and is not an admin" do
    marnen = users(:marnen) # current user
    marnen.stub!(:role).and_return(mock_model(Role, :name => 'user')) # make him non-admin
    User.stub!(:current_user).and_return(marnen)
    event = Event.find(:first)
    event.stub!(:created_by).and_return(users(:quentin))
    get 'edit', :id => event.id
    flash[:error].should_not be_nil
    response.should redirect_to(:action => :index)
    marnen.stub!(:role).and_return(mock_model(Role, :name => 'admin'))
    get 'edit', :id => event.id
    flash[:error].should be_nil
    response.should_not redirect_to(:action => :index)
  end
  
  it "should reuse the new-event form" do
    event = Event.find(:first)
    get 'edit', :id => event.id
    response.should render_template(:new)
  end
  
  it "should set the page title" do
    event = Event.find(:first)
    get 'edit', :id => event.id
    assigns[:page_title].should_not be_nil
  end
  
  it "should set the event" do
    event = Event.find(:first)
    get 'edit', :id => event.id
    assigns[:event].should == event
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

describe EventsController, "delete" do
  fixtures :users, :roles, :events
  
  before(:each) do
    @event = Event.find(:first)
    @id = @event.id
  end
  
  it "should not work from non-admin account" do
    login_as :quentin
    @event.should_not_receive(:hide)
    post 'delete', :id => @id
    User.current_user.role.name.should_not == 'admin'
    flash[:error].should_not be_nil
  end
  
  it "should work from admin account" do
    login_as :marnen
    Event.should_receive(:find).with(@id.to_i).and_return(@event)
    @event.should_receive(:hide)
    post 'delete', :id => @id
    User.current_user.role.name.should == 'admin'
    flash[:error].should be_nil
  end
end

describe EventsController, "map" do
  fixtures :users, :events, :states, :countries
  
  before(:each) do
    login_as :marnen
    @one = events(:one)
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
  fixtures :events, :users, :states, :countries
  
  before(:each) do
    login_as :quentin
    @my_event = Event.new do |e| # arbitrary values
      e.id = 63
      e.name = "Test"
      e.date = Time.now
      e.state = states(:ny)
    end
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
    response.headers['type'].should =~ (%r{^text/calendar})
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