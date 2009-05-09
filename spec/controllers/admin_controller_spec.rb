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
    login_as User.make
    @one = Calendar.make(:id => 1)
    @two = Calendar.make(:id => 2)
    @current_user = User.make do |u|
      u.permissions.make(:calendar => @one)
      u.permissions.make(:admin, :calendar => @two)
    end
    
    login_as @current_user
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
