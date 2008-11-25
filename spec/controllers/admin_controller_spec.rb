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

describe AdminController, "(index)" do
  integrate_views
  
  before(:each) do
    @one = mock_model(Calendar, :name => 'Calendar 1', :id => 1)
    @two = mock_model(Calendar, :name => 'Calendar 2', :id => 2)
    @user = mock_model(Role, :name => 'user', :id => 27)
    @permissions = [mock_model(Permission, :calendar => @one, :role => @user), mock_model(Permission, :calendar => @two, :role => @admin)]
    @permissions.should_receive(:find_all_by_role_id).with(user_role, anything).any_number_of_times.and_return([@permissions[0]])
    @permissions.should_receive(:find_all_by_role_id).with(admin_role, anything).any_number_of_times.and_return([@permissions[1]])
    @current_user = mock_model(User, :permissions => @permissions, :admin? => true)
    User.stub!(:current_user).and_return(@current_user)
    controller.stub!(:admin?).and_return(true)
    get :index
  end
  
  it "should set the page title" do
    assigns[:page_title].should_not be_nil
  end
  
  it "should show a list of calendars for which the current user is an administrator, along with edit and users links" do
    assigns[:calendars].should_not be_nil
    assigns[:calendars].should include(@two)
    assigns[:calendars].should_not include(@one)
    response.should have_tag('li#calendar_2 a', /users/i)
  end
end
