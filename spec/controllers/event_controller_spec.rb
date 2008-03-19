require File.dirname(__FILE__) + '/../spec_helper'

describe EventController, "list" do
  fixtures :users
  
  before(:each) do
    login_as(:quentin)
  end
  
  it "should be successful" do
   get 'list'
   response.should be_success
  end
 
  it "should set the page_title" do
    get :list
    assigns[:page_title].should_not be_nil
  end
  
  it "should get all non-deleted events, with distance, ordered by date" do
    Event.should_receive(:find).with(:all, :order => :date, :conditions => 'deleted != true').once
    get 'list'
  end
end

describe EventController, "change_status" do
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
  
  it "should redirect to list" do
    get 'change_status'
    response.should redirect_to(:action => :list)
  end
end

describe EventController, "new" do
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
  
  it "should save an Event object" do
    my_event = Event.new(:name => 'name', :state_id => 23)
    my_event.should_not be_nil
    my_event.created_by_id.should be_nil
    Event.stub!(:new).and_return(my_event)
    User.current_user.stub!(:id).and_return(3) # arbitrary value
    my_event.should_receive(:save)
    post 'new', :event => my_event.attributes
    # assigns[:event].name.should == my_event.name
    # assigns[:event].id.should_not be_nil
    # assigns[:event].created_by_id.should == User.current_user.id
  end
  
  it "should redirect to event list with flash after post with successful save, but not otherwise" do
    get 'new'
    response.should_not redirect_to(:action => :list)

    my_event = Event.new #invalid
    post 'new', :event => my_event.attributes
    response.should_not redirect_to(:action => :list)
    
    my_event = Event.new(:name => 'name', :state_id => 23) #valid
    post 'new', :event => my_event.attributes
    response.should redirect_to(:action => :list)
    flash[:notice].should_not be_nil
  end
  
end

describe EventController, "edit" do
  fixtures :users, :events
  
  before(:each) do
    login_as :quentin
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
  
  it "should redirect to list with a flash error if no event id is supplied or if id is invalid" do
    get 'edit', :id => 'a' # invalid
    response.should redirect_to(:action => :list)
    flash[:error].should_not be_nil

    get 'edit', :id => nil # no id
    response.should redirect_to(:action => :list)
    flash[:error].should_not be_nil
  end
  
  it "should redirect to event list with flash after post with successful save, but not otherwise" do
    event = Event.find(:first)
    id = event.id
    post 'edit', :event => event.attributes, :id => id # valid
    request.should be_post
    assigns[:event].should_receive(:update_attributes)
    response.should redirect_to(:action => :list)
    flash[:notice].should_not be_nil
    
    event.name = nil # now it's invalid
    post 'edit', :event => event.attributes, :id => id
    response.should_not redirect_to(:action => :list)
  end
  
  it "should reset coords to nil when saving" do
    event = Event.find(:first)
    id = event.id
    event.coords.should_not be_nil
    Event.should_receive(:find).with(id.to_i).twice.and_return(event, Event.find_by_id(id))
    event.should_receive(:update_attributes).with(an_instance_of(Hash)).once
    post 'edit', :event => event.attributes, :id => id
    event = Event.find(id)
    event.should_receive(:coords_from_string).once # calling event.coords should trigger recoding
    event.coords
  end
end

describe EventController, "map" do
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

describe EventController, "export" do
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
    response.should render_template('event/ical.ics.erb')
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
  it "should use EventController" do
    controller.should be_an_instance_of(EventController)
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