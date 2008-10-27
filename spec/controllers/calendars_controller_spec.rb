require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe 'uses_admin', :shared => true do
  before(:each) do
    controller.stub!(:check_admin).and_return(true)
    @current_user = mock_model(User, :admin? => true)
    User.stub!(:current_user).and_return(@current_user)
  end
end

describe 'uses_login', :shared => true do
  before(:each) do
    @current_user = mock_model(User, :admin? => false)
    User.stub!(:current_user).and_return(@current_user)
    controller.stub!(:login_required).and_return(true)
  end
end

describe CalendarsController, 'new' do
  it_should_behave_like 'uses_login'
  
  it 'should not require admin permissions' do
    get :new
    response.should be_success
  end
  
  it 'should require login' do
    pending 'not stubbing login_required properly yet' do
      User.stub!(:current_user).and_return(false)
      controller.stub!(:login_required).and_return(false)
      get :new
      response.should_not be_success
    end
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

describe CalendarsController, 'edit' do
  it_should_behave_like 'uses_admin'
  integrate_views
  
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
