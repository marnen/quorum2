require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe 'uses_admin', :shared => true do
  before(:each) do
    controller.stub!(:check_admin).and_return(true)
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
