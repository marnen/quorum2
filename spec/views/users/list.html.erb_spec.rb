require File.dirname(__FILE__) + '/../../spec_helper'

include ERB::Util

describe "/users/list" do
  fixtures :users, :states, :countries
  before(:all) do
    @all_users = User.find(:all, :order => 'lastname, firstname')
    User.stub!(:find).with(:all).and_return(@all_users)
  end
  
  before(:each) do
    assigns[:users] = @users = User.find(:all)
    render 'users/list'
  end
  
  it "should show the results in a table" do
    response.should have_tag("table.users")
  end
  
  it "should show first and last names for each user" do
    for u in @users
      response.should have_tag(".users td", /#{h(u.firstname)}/)
      response.should have_tag(".users td", /#{h(u.lastname)}/)
    end
  end
  
  it "should show addresses for each user" do
    for u in @users
      response.should have_tag(".users td", /#{h(u.street)}.*#{h(u.street2)}.*#{h(u.city)}.*#{h(u.state.code)}/)
    end
  end
end
