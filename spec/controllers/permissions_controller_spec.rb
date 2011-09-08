require 'spec_helper'

include ActionView::Helpers::UrlHelper

describe PermissionsController do

  #Delete this example and add some real ones
  it "should use PermissionsController" do
    controller.should be_an_instance_of(PermissionsController)
  end

end

describe PermissionsController, 'index' do
  render_views
  
  before(:each) do
    @user = FactoryGirl.create :role, :name => 'user'
    @admin = FactoryGirl.create :admin_role
    @current_user = FactoryGirl.create :user, :email => 'johndoe@example.com'
    @one = FactoryGirl.create :calendar, :name => 'Calendar 1'
    @two = FactoryGirl.create :calendar, :name => 'Calendar 2'
    @three = FactoryGirl.create :calendar, :name => 'Calendar 3'
    [{:role => @user, :calendar => @one}, {:role => @admin, :calendar => @two}].each do |opts|
      @current_user.permissions << FactoryGirl.create(:permission, opts)
    end
    UserSession.create @current_user
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
    assigns[:permissions].should == @current_user.permissions
  end
  
  it 'should list each subscribed calendar by name in a table' do
    get :index
    @current_user.permissions.each do |p|
      cal = p.calendar
      response.should have_tag("tr#permission_#{p.id} td#calendar_#{cal.id}", %r{#{Regexp.escape(ERB::Util::html_escape(cal))}})
    end
  end
  
  it 'should list the role for each subscribed calendar in the table' do
    get :index
    @current_user.permissions.each do |p|
      response.should have_tag("tr#permission_#{p.id} td", %r{#{Regexp.escape(ERB::Util::html_escape(p.role))}})
    end
  end
  
  it 'should have an unsubscribe link for each non-admin subscription' do
    admin, nonadmin = @current_user.permissions.partition{|p| p.role_id == @admin.id}.collect{|a| a[0]}
    get :index
    response.should have_tag("tr#permission_#{nonadmin.id} td.actions a.unsubscribe[href=#{url_for(:action => 'destroy', :id => nonadmin.id, :escape => false)}]")
    response.should_not have_tag("tr#permission_#{admin.id} td.actions a.unsubscribe[href=#{url_for(:action => 'destroy', :id => admin.id, :escape => false)}]")
  end
  
  it 'should show a list of unsubscribed calendars to subscribe to' do
    @current_user.permissions.find_by_calendar_id(@three.id).should be_nil
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
  render_views
  
  it 'should show all available calendars under "unsubscribed"' do
    @current_user = FactoryGirl.create :user, :id => 20, :email => 'no_permissions@gmail.com'
    2.times do
      FactoryGirl.create :calendar
    end
    UserSession.create @current_user
    get :index
    assigns[:permissions].should be_empty
    
    response.should have_tag('table.unsubscribed')
  end
end
  
describe PermissionsController, 'index (no unsubscribed calendars)' do
  it 'should not show the list of unsubscribed calendars if there are none' do
    Calendar.count.should == 0
    get :index
    assigns[:unsubscribed].should be_nil
    response.should_not have_tag('table.unsubscribed')
  end
end

describe PermissionsController, 'subscribe' do
  before(:each) do
    @calendar = FactoryGirl.create :calendar
    @user = FactoryGirl.create :role, :id => 20, :name => 'user'
    @params = {:calendar_id => @calendar.id}
    @current_user = FactoryGirl.create :user, :email => 'test@example.com', :id => 18
    controller.stub!(:check_admin).and_return(false)
    UserSession.create @current_user
  end
  
  it 'should be a valid non-admin action' do
    get :subscribe, :calendar_id => @calendar.id
    response.should be_redirect
  end
  
  it "should create a new permission for the current user and the given calendar, if there isn't one already" do
    conditions = {:calendar_id => @calendar.id, :user_id => @current_user.id, :role_id => @user.id}
    Permission.destroy(Permission.find(:all, :conditions => conditions).collect{|p| p.id})
    @pcount = Permission.count
    get :subscribe, :calendar_id => @calendar.id
    Permission.count.should == @pcount + 1
    Permission.find(:first, :conditions => conditions).should_not be_nil
  end
  
  it "should not create a new permission if there's already one (at user level) for the current user and given calendar" do
    opts = {:calendar_id => @calendar.id, :user_id => @current_user.id, :role_id => @user.id}
    Permission.create opts
    @pcount = Permission.count
    get :subscribe, :calendar_id => @calendar.id
    Permission.count.should == @pcount
  end
end

describe PermissionsController, 'destroy' do
  before(:each) do
    @current_user = FactoryGirl.create :user, :id => 12, :email => 'johndoe@example.com'
    @current_user.stub!(:admin?).and_return false
    UserSession.create @current_user
    request.env['HTTP_REFERER'] = 'referer'
  end
  
  it 'should be a valid non-admin action' do
    Permission.stub!(:find).and_return(mock_model(Permission, :null_object => true))
    controller.should_not_receive(:check_admin)
    get :destroy, :id => 1
  end
  
  it 'should delete the Permission given by the id parameter if it belongs to the current user' do
    @mine = FactoryGirl.create :permission, :id => 90, :user => @current_user
    @mine.should_receive(:destroy)
    Permission.should_receive(:find).with(@mine.id.to_param).and_return(@mine)
    get :destroy, :id => @mine.id
  end
  
  it 'should not delete the Permission given by the id parameter if it does not belong to the current user' do
    @notmine = FactoryGirl.create :user, :permissions => [FactoryGirl.create :permission, :id => 91]
    @notmine.should_not_receive(:destroy)
    Permission.should_receive(:find).with(@notmine.id.to_param).and_return(@notmine)
    get :destroy, :id => @notmine.id
    response.should be_redirect
    flash[:error].should_not be_blank
  end
end


