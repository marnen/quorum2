require 'spec_helper'

describe 'uses_admin', :shared => true do
  before(:each) do
    controller.stub!(:check_admin).and_return(true)
    @current_user = User.make
    @current_user.stub!(:admin?).and_return(true)
    UserSession.create @current_user
  end
end

describe 'uses_login', :shared => true do
  before(:each) do
    @current_user = User.make
    @current_user.stub!(:admin?).and_return(false)
    UserSession.create @current_user
  end
end

describe CalendarsController, 'new' do
  it_should_behave_like 'uses_login'
  
  it 'should not require admin permissions' do
    get :new
    response.should be_success
  end
  
  it 'should require login' do
    session = UserSession.find
    session.destroy if session
    controller.stub!(:require_user).and_return(false)
    get :new
    response.body.should be_blank
  end
  
  it 'should share the same template with the edit action' do
    get :new
    response.should render_template 'edit'
  end
  
  it 'should set the page title' do
    get :new
    assigns[:page_title].should_not be_nil
  end
end

describe CalendarsController, 'create' do
  it_should_behave_like 'uses_login'
  
  before(:each) do
    @plan = Calendar.plan(:name => 'Test calendar')
    post :create, :calendar => @plan
  end
  
  it 'should not require admin permissions' do
    response.should redirect_to('/admin')
  end
  
  it 'should create admin permissions on the new calendar' do
    cal = Calendar.find_by_name(@plan[:name])
    cal.should_not be_nil
    Permission.find_by_calendar_id_and_user_id(cal.id, @current_user.id).should_not be_nil
  end
end

describe CalendarsController, 'edit' do
  it_should_behave_like 'uses_admin'
  render_views
  
  before(:each) do
    @calendar = mock_model(Calendar, :id => 1, :name => 'Calendar 1')
    Calendar.stub!(:find).and_return(@calendar)
    get :edit, :id => @calendar.id
  end
  
  it 'should be a valid action' do
    response.should be_success
  end
  
  it 'should set the page title' do
    assigns[:page_title].should_not be_nil
  end
  
  it 'should provide a form for editing the calendar' do
    response.should have_tag('form table.edit')
  end
  
  it 'should provide a name field for the calendar' do
    response.should have_tag('form input#calendar_name')
  end
end

describe CalendarsController, 'users' do
  it_should_behave_like 'uses_admin'
  
  before(:each) do
    @calendar = mock_model(Calendar, :id => 1, :name => 'Calendar 1')
    Calendar.stub!(:find).and_return(@calendar)
    @users = [mock_model(User), mock_model(User), mock_model(User)]
    @users.should_receive(:find).with(:all, :order => 'lastname, firstname').and_return(@users)
    @calendar.stub!(:users).and_return(@users)
  end

  it "should be a valid action" do
    get :users, :id => @calendar.id
    response.should be_success
  end
  
  it "should set the page title" do
    get :users, :id => @calendar.id
    assigns[:page_title].should_not be_nil
  end
  
  it "should use the users template" do
    get :users, :id => @calendar.id
    response.should render_template :users
  end
  
  it "should get a list of users" do
    get :users, :id => @calendar.id
    assigns[:users].should_not be_nil
    assigns[:users].should be_a_kind_of(Array)
    assigns[:users].should == @users
  end
end
