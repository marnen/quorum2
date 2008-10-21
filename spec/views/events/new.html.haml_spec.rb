require File.dirname(__FILE__) + '/../../spec_helper'

describe "/events/new" do
  fixtures :users, :events
  
  before(:each) do
    login_as :quentin
    User.stub!(:current_user).and_return(users(:quentin))
    assigns[:current_object] = events(:one)
    render 'events/new'
  end
  
  it "should have a form" do
    response.should have_tag("form")
  end
  
  it "should have a table of class edit in the form" do
    response.should have_tag("form table.edit")
  end
  
  it "should have a name field" do
    response.should have_tag("table.edit input#event_name")
  end
  
  it "should have a description field" do
    response.should have_tag("table.edit textarea#event_description")
  end
  
  it "should have a Markdown hint in the description field" do
    header = assert_select("table.edit th", /Description/)
    header.should_not be_nil
    header.should have_tag("a", 'Markdown')
  end
  
  it "should have a date selector" do
    response.should have_tag("table.edit select#event_date_2i")
  end

  it "should have a site field" do
    response.should have_tag("table.edit input#event_site")
  end
  
  it "should have two address fields" do
    response.should have_tag("table.edit input#event_street")
    response.should have_tag("table.edit input#event_street2")
  end
  
  it "should have a city field" do
    response.should have_tag("table.edit input#event_city")
  end
  
  it "should have a state field" do
    response.should have_tag("table.edit select#event_state_id")
  end
  
  it "should have a zip field" do
    response.should have_tag("table.edit input#event_zip")
  end
  
  it "should have a submit button" do
    response.should have_tag("form input[type=submit]")
  end
  
end

describe "/events/new (multiple calendars)" do
  before(:each) do
    @one = mock_model(Calendar, :id => 1, :name => 'Calendar 1')
    @two = mock_model(Calendar, :id => 2, :name => 'Calendar 2')
    assigns[:current_object] = mock_model(Event, :null_object => true, :date => Time.now, :calendar => @one)
  end
  
  it "should display a calendar selector if current user has multiple calendars" do
    @quentin = mock_model(User, :id => 5, :calendars => [@one, @two])
    User.stub!(:current_user).and_return(@quentin)
    render '/events/new'
    response.should have_tag('select#event_calendar_id')
  end
  
  it "should not display a calendar selector if current user only has one calendar" do
    @jim = mock_model(User, :id => 6, :calendars => [@one])
    User.stub!(:current_user).and_return(@jim)
    render '/events/new'
    response.should_not have_tag('select#event_calendar_id')
    response.should have_tag("input[type=hidden][value=#{@one.id}]#event_calendar_id")
  end
end
