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
    @three = mock_model(Calendar, :id => 3, :name => 'Calendar 3')
    Calendar.should_receive(:find) do |arg1, hash|
      arg1.should == :all
      hash.should be_an_instance_of Hash
      hash.should have_key(:conditions)
      hash[:conditions][0].should =~ /^id NOT IN/
      [@three]
    end
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
  
  it 'should list each subscribed calendar by name in a table' do
    @permissions.each do |p|
      cal = p.calendar
      response.should have_tag("tr#permission_#{p.id} td#calendar_#{cal.id}", %r{#{Regexp.escape(ERB::Util::html_escape(cal))}})
    end
  end
  
  it 'should list the role for each subscribed calendar in the table' do
    @permissions.each do |p|
      response.should have_tag("tr#permission_#{p.id} td", %r{#{Regexp.escape(ERB::Util::html_escape(p.role))}})
    end
  end
    
  it 'should show a list of unsubscribed calendars to subscribe to' do
    response.should have_tag("table.unsubscribed tr#calendar_#{@three.id}") do |r|
      r.should have_tag("a[href=#{subscribe_path(:calendar_id => @three.id)}]")
    end
    [@one, @two].each do |c|
      response.should_not have_tag("table.unsubscribed tr#calendar_#{c.id}")
    end
  end
end

describe PermissionsController, 'subscribe' do
  before(:each) do
    [Calendar, User, Role].each do |m|
      m.stub!(:find).and_return(mock_model(m))
    end
    @params = {:calendar_id => 1, :user_id => 2, :role_id => 3}
    controller.stub!(:login_required).and_return(true)
    controller.stub!(:check_admin).and_return(false)
  end
  
  it 'should be a valid non-admin action' do
    get :subscribe, :calendar_id => 1
    response.should be_success
  end
end


