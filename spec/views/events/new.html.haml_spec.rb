# coding: UTF-8

require 'spec_helper'

describe "/events/new" do
  before(:each) do
    user = FactoryGirl.create(:user).tap {|u| u.permissions << FactoryGirl.create(:permission, :user => u) }
    UserSession.create user
    [User, view].each {|x| x.stub(:current_user).and_return user }
    assign :event, FactoryGirl.create(:event)
    render :file => 'events/new'
  end

  it "should have a form" do
    rendered.should have_selector("form")
  end

  it "should have a table of class edit in the form" do
    rendered.should have_selector("form table.edit")
  end

  it "should have a name field" do
    rendered.should have_selector("table.edit input#event_name")
  end

  it "should have a description field" do
    rendered.should have_selector("table.edit textarea#event_description")
  end

  it "should have a Markdown hint in the description field" do
    header = assert_select("table.edit th", /Description/)
    header.should_not be_nil
    header.should have_selector("a", :content => 'Markdown')
  end

  it "should have a date selector" do
    rendered.should have_selector("table.edit select#event_date_2i")
  end

  it "should have a site field" do
    rendered.should have_selector("table.edit input#event_site")
  end

  it "should have two address fields" do
    rendered.should have_selector("table.edit input#event_street")
    rendered.should have_selector("table.edit input#event_street2")
  end

  it "should have a city field" do
    rendered.should have_selector("table.edit input#event_city")
  end

  it "should have a state field" do
    rendered.should have_selector("table.edit select#event_state_id")
  end

  it "should have a zip field" do
    rendered.should have_selector("table.edit input#event_zip")
  end

  it "should have a submit button" do
    rendered.should have_selector("form input[type=submit]")
  end

end

describe "/events/new (multiple calendars)" do
  before(:each) do
    @one = FactoryGirl.create :calendar
    @two = FactoryGirl.create :calendar
    assign :event, FactoryGirl.create(:event, :date => Time.now, :calendar => @one)
    @user = FactoryGirl.create :user, :permissions => []
    UserSession.create @user
    [User, view].each {|x| x.stub(:current_user).and_return @user }
  end

  it "should display a calendar selector if current user has multiple calendars" do
    [@one, @two].each do |c|
      @user.permissions << FactoryGirl.create(:permission, :user => @user, :calendar => c)
    end
    render :file => '/events/new'
    rendered.should have_selector('select#event_calendar_id')
  end

  it "should not display a calendar selector if current user only has one calendar" do
    @user.permissions << FactoryGirl.create(:permission, :user => @user, :calendar => @one)
    render :file => '/events/new'
    rendered.should_not have_selector('select#event_calendar_id')
    rendered.should have_selector("input[type=hidden][value='#{@one.id}']#event_calendar_id")
  end
end
