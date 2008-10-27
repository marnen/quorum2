require File.dirname(__FILE__) + '/../../spec_helper'

include ERB::Util

describe "/calendars/users" do
  fixtures :users, :states, :countries
  before(:all) do
    @all_users = User.find(:all, :order => 'lastname, firstname')
    User.stub!(:find).with(:all).and_return(@all_users)
  end
  
  before(:each) do
    assigns[:users] = @users = User.find(:all)
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
end
