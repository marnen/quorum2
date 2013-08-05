# coding: UTF-8

require 'spec_helper'

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