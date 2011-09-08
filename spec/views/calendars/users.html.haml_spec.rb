require 'spec_helper'

include ERB::Util

describe "/calendars/users" do
  before(:each) do
    @calendar = mock_model(Calendar, :name => 'Test calendar')
    
    @admin_role = mock_model(Role, :to_s => 'admin')
    @user_role = mock_model(Role, :to_s => 'user')
    
    @admin = mock_model(Permission, :calendar => @calendar, :role => @admin_role, :null_object => true)
    @user = mock_model(Permission, :calendar => @calendar, :role => @user_role, :null_object => true)
    
    null_option = false
    
    @marnen = mock_model(User, :id => 1, :firstname => 'Marnen', :lastname => 'Laibow-Koser', :email => 'marnen@marnen.org', :permissions => [@admin], :show_contact => true, :null_object => null_option)
    @millie = mock_model(User, :id => 2, :firstname => 'Millie', :lastname => 'Cady', :email => 'marnen@marnen.org', :permissions => [@user], :show_contact => true, :null_object => null_option)
    @quentin = mock_model(User, :id => 3, :firstname => 'Quentin', :lastname => 'Quackenbush', :email => 'marnen@marnen.org', :permissions => [@user], :show_contact => false, :null_object => null_option)
    @all_users = [@millie, @marnen, @quentin]
    @all_users.each do |u|
      p = u.permissions[0]
      u.permissions.stub!(:find_by_calendar_id).and_return(p)
      u.stub!(:state).and_return Factory(:state)
      u.stub!(:street).and_return('123 Main Street')
      u.stub!(:street2).and_return('x')
      u.stub!(:city).and_return('Somewhere')
      u.stub!(:zip).and_return('12345')
    end
    User.should_receive(:find).with(:all).any_number_of_times.and_return(@all_users)
    User.stub!(:current_user).and_return(@marnen)

    assigns[:users] = @users = @all_users
    assigns[:current_object] = @calendar
    render 'calendars/users'
  end
  
  it "should show the results in a table" do
    response.should have_tag("table.users")
  end
  
  it "should show first and last names for each user" do
    for u in @users
      response.should have_tag("tr#user_#{u.id} td._name", /#{h(u.firstname)}/)
      response.should have_tag("tr#user_#{u.id} td._name", /#{h(u.lastname)}/)
    end
  end
  
  it "should show street and e-mail addresses for each user who has not requested to be hidden" do
    for u in @users
      response.should have_tag("tr#user_#{u.id}") do |row|
        if u.show_contact
          row.should have_tag('td._address',
            Regexp.new([u.street, u.street2, u.city, u.state.code].collect{|x| Regexp.escape(h x)}.join('.*')))
          row.should have_tag('td._email', h(u.email))
        else
          row.should have_tag("td._address", "")
          row.should_not have_tag("td._email *", h(u.email))
        end
      end
    end
  end
  
  it "should show each user's role in this calendar, and -- except for the current user -- should allow it to be changed" do
    for u in @users
      response.should have_tag("tr#user_#{u.id}") do |row|
        if u == User.current_user
          row.should have_tag("td._role", /admin/) # just text
          row.should_not have_tag("td._role select" )
        else
          row.should have_tag("td._role select" )
        end
      end
    end
  end
  
  it "should show whether each user is visible on commitment reports" do
    for u in @users
      response.should have_tag("tr#user_#{u.id} td._show input[type=checkbox]")
    end
  end
end
