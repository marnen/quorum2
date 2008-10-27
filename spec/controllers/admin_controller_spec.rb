require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

def user_role
  simple_matcher('a user Role object') do |given|
    given.instance_of? Role and given.name == 'user'
  end
end

def admin_role
  simple_matcher('an admin Role object') do |given|
    given.instance_of? Role and given.name == 'admin'
  end
end

describe "uses admin", :shared => true do
  before(:each) do
    @admin = mock_model(Role, :name => 'admin', :id => 15)
    Role.stub!(:find_by_role_id).with('admin').and_return(@admin)
  end
end

describe AdminController do
  it_should_behave_like "uses admin"
  
  it "should not let non-admin users in" do
    User.stub!(:current_user).and_return(mock_model(User, :permissions => []))
    get :index
    response.should be_redirect
    flash[:error].should_not be_nil
  end
  
  it "should let admin users in" do
    @permissions = [mock_model(Permission, :calendar => mock_model(Calendar), :role => @admin)]
    @permissions.stub!(:find_by_role_id).and_return(@permissions[0])
    User.stub!(:current_user).and_return(mock_model(User, :permissions => @permissions))
    get :index
    response.should be_success
    flash[:error].should be_nil
  end
end

describe AdminController, "(index)" do
  it_should_behave_like "uses admin"
  integrate_views
  
  before(:each) do
    @one = mock_model(Calendar, :name => 'Calendar 1')
    @two = mock_model(Calendar, :name => 'Calendar 2')
    @user = mock_model(Role, :name => 'user', :id => 27)
    @permissions = [mock_model(Permission, :calendar => @one, :role => @user), mock_model(Permission, :calendar => @two, :role => @admin)]
    @permissions.should_receive(:find_by_role_id).with(user_role, anything).any_number_of_times.and_return(@permissions[0])
    @permissions.should_receive(:find_by_role_id).with(admin_role, anything).any_number_of_times.and_return(@permissions[1])
    @current_user = mock_model(User, :permissions => @permissions)
    User.stub!(:current_user).and_return(@current_user)
    get :index
  end
  
  it "should set the page title" do
    assigns[:page_title].should_not be_nil
  end
  
  it "should show a list of calendars for which the current user is an administrator" do
    assigns[:calendars].should_not be_nil
    assigns[:calendars].should include(@two)
    assigns[:calendars].should_not include(@one)
  end
end
