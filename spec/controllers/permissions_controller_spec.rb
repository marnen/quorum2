require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe PermissionsController do

  #Delete this example and add some real ones
  it "should use PermissionsController" do
    controller.should be_an_instance_of(PermissionsController)
  end

end

describe PermissionsController, 'index' do
  integrate_views
  
  before(:each) do
    controller.stub!(:login_required).and_return(true)
    @user = mock_model(Role, :name => 'user')
    @admin = mock_model(Role, :name => 'admin')
    @current_user = mock_model(User, :id => 15, :email => 'johndoe@example.com', :admin? => false)
    @one = mock_model(Calendar, :id => 1, :name => 'Calendar 1')
    @two = mock_model(Calendar, :id => 2, :name => 'Calendar 2')
    @permissions = [
      mock_model(Permission, :user => @current_user, :role => @user, :calendar => @one),
      mock_model(Permission, :user => @current_user, :role => @admin, :calendar => @two)
    ]
    @permissions.should_receive(:find).and_return(@permissions)
    @current_user.should_receive(:permissions).and_return(@permissions)
    User.stub!(:current_user).and_return(@current_user)
    get :index
  end
  
  it 'should be a valid action' do
    response.should be_success
  end
  
  it 'should set the page title' do
    assigns[:page_title].should_not be_nil
  end
  
  it "should get all of the current user's permissions" do
    assigns[:permissions].should == @permissions
  end
  
  it 'should list each calendar by name in a table' do
    @permissions.each do |p|
      cal = p.calendar
      response.should have_tag("tr#permission_#{p.id} td#calendar_#{cal.id}", %r{#{Regexp.escape(ERB::Util::html_escape(cal))}})
    end
  end
  
  it 'should list the role for each calendar in the table' do
    @permissions.each do |p|
      response.should have_tag("tr#permission_#{p.id} td", %r{#{Regexp.escape(ERB::Util::html_escape(p.role))}})
    end
  end
    
end


