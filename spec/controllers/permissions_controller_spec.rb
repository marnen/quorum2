require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

include ActionView::Helpers::UrlHelper

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
  end
  
  it 'should be a valid action' do
    get :index
    response.should be_success
  end
  
  it 'should set the page title' do
    get :index
    assigns[:page_title].should_not be_nil
  end
  
  it "should get all of the current user's permissions" do
    get :index
    assigns[:permissions].should == @permissions
  end
  
  it 'should list each subscribed calendar by name in a table' do
    get :index
    @permissions.each do |p|
      cal = p.calendar
      response.should have_tag("tr#permission_#{p.id} td#calendar_#{cal.id}", %r{#{Regexp.escape(ERB::Util::html_escape(cal))}})
    end
  end
  
  it 'should list the role for each subscribed calendar in the table' do
    get :index
    @permissions.each do |p|
      response.should have_tag("tr#permission_#{p.id} td", %r{#{Regexp.escape(ERB::Util::html_escape(p.role))}})
    end
  end
  
  it 'should have an unsubscribe link for each non-admin subscription' do
    get :index
    response.should have_tag("tr#permission_#{@permissions[0].id} td.actions a.unsubscribe[href=#{url_for(:action => 'destroy', :id => @permissions[0].id, :escape => false)}]")
    response.should_not have_tag("tr#permission_#{@permissions[1].id} td.actions a.unsubscribe[href=#{url_for(:action => 'destroy', :id => @permissions[1].id, :escape => false)}]")
  end
  
  it 'should show a list of unsubscribed calendars to subscribe to' do
    get :index
    response.should have_tag("table.unsubscribed tr#calendar_#{@three.id}") do |r|
      r.should have_tag("a[href=#{subscribe_path(:calendar_id => @three.id)}]")
    end
    [@one, @two].each do |c|
      response.should_not have_tag("table.unsubscribed tr#calendar_#{c.id}")
    end
  end
end

describe PermissionsController, 'index (no subscribed calendars)' do  
  integrate_views
  
  before(:each) do
    controller.stub!(:login_required).and_return(true)
  end
  
  it 'should show all available calendars under "unsubscribed"' do
    @blank = []
    @blank.should_receive(:find).and_return([])
    @current_user = mock_model(User, :id => 20, :email => 'no_permissions@gmail.com', :admin? => false)
    @current_user.should_receive(:permissions).and_return(@blank)
    @calendars = [mock_model(Calendar, :id => 1), mock_model(Calendar, :id => 2)]
    Calendar.should_receive(:find).with(:all).and_return(@calendars)
    User.stub!(:current_user).and_return(@current_user)
    get :index
    assigns[:permissions].should == @blank
    
    response.should have_tag('table.unsubscribed')
  end
end
  
describe PermissionsController, 'index (no unsubscribed calendars)' do
  it 'should not show the list of unsubscribed calendars if there are none' do
    Calendar.stub!(:find).and_return(nil)
    get :index
    assigns[:unsubscribed].should be_nil
    response.should_not have_tag('table.unsubscribed')
  end
end

describe PermissionsController, 'subscribe' do
  before(:each) do
    Calendar.stub!(:find).and_return(mock_model(Calendar, :id => 1))
    @user = mock_model(Role, :id => 20, :name => 'user')
    Role.stub!(:find_by_name).and_return(@user)
    @params = {:calendar_id => 1}
    @pcount = Permission.count
    @current_user = mock_model(User, :email => 'test@example.com', :id => 18)
    controller.stub!(:login_required).and_return(true)
    controller.stub!(:check_admin).and_return(false)
    User.stub!(:current_user).and_return(@current_user)
    get :subscribe, :calendar_id => 1
  end
  
  it 'should be a valid non-admin action' do
    response.should be_redirect
  end
  
  it 'should create a new permission for the current user and the given calendar' do
    Permission.count.should == @pcount + 1
    Permission.find(:first, :conditions => {:calendar_id => 1, :user_id => @current_user.id, :role_id => @user.id}).should_not be_nil
  end
end

describe PermissionsController, 'destroy' do
  before(:each) do
    controller.stub!(:login_required).and_return(true)
    @current_user = mock_model(User, :id => 12, :email => 'johndoe@example.com', :admin? => false)
    User.stub!(:current_user).and_return(@current_user)
    request.env['HTTP_REFERER'] = 'referer'
  end
  
  it 'should be a valid non-admin action' do
    Permission.stub!(:find).and_return(mock_model(Permission, :null_object => true))
    controller.should_not_receive(:check_admin)
    get :destroy, :id => 1
  end
  
  it 'should delete the Permission given by the id parameter if it belongs to the current user' do
    @mine = mock_model(Permission, :id => 90, :null_object => true, :user_id => @current_user.id)
    @mine.should_receive(:destroy)
    Permission.should_receive(:find).with(@mine.id.to_param).and_return(@mine)
    get :destroy, :id => @mine.id
  end
  
  it 'should not delete the Permission given by the id parameter if it does not belong to the current user' do
    @notmine = mock_model(Permission, :id => 91, :null_object => true, :user_id => @current_user.id + 3)
    @notmine.should_not_receive(:destroy)
    Permission.should_receive(:find).with(@notmine.id.to_param).and_return(@notmine)
    get :destroy, :id => @notmine.id
    response.should be_redirect
    flash[:error].should_not be_blank
  end
end


