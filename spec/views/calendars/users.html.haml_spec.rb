require File.dirname(__FILE__) + '/../../spec_helper'

include ERB::Util

describe "/calendars/users" do
  fixtures :users, :states, :countries, :permissions, :calendars
  before(:all) do
    @all_users = User.find(:all, :order => 'lastname, firstname')
    User.stub!(:find).with(:all).and_return(@all_users)
    User.stub!(:current_user).and_return(User.find_by_email('marnen@marnen.org'))
  end
  
  before(:each) do
    assigns[:users] = @users = User.find(:all)
    assigns[:current_object] = @calendar = calendars(:one)
    render 'calendars/users'
  end
  
  it "should show the results in a table" do
    response.should have_tag("table.users")
  end
  
  it "should show first and last names for each user" do
    for u in @users
      response.should have_tag("tr#user_#{u.id} td", /#{h(u.firstname)}/)
      response.should have_tag("tr#user_#{u.id} td", /#{h(u.lastname)}/)
    end
  end
  
  it "should show street and e-mail addresses for each user who has not requested to be hidden" do
    for u in @users
      if u.show_contact
        response.should have_tag("tr#user_#{u.id} td", /#{h(u.street)}.*#{h(u.street2)}.*#{h(u.city)}.*#{h(u.state.code)}/)
        response.should have_tag("tr#user_#{u.id} td", h(u.email))
      else
        response.should have_tag("tr#user_#{u.id} td", "")
        response.should_not have_tag("tr#user_#{u.id} *", h(u.email))
      end
    end
  end
  
  it "should show each user's role in this calendar, and -- except for the current user -- should allow it to be changed" do
    for u in @users
      if u == User.current_user
        response.should have_tag("tr#user_#{u.id} td", /admin/) # just text
        response.should_not have_tag("tr#user_#{u.id} td select" )
      else
        response.should have_tag("tr#user_#{u.id} td select" )
      end
    end
  end
end
