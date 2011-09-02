require 'spec_helper'

describe "/users/new" do
  before(:each) do
    render 'users/new'
  end
  
  it "should have a form" do
    response.should have_tag("form")
  end
  
  it "should have a table of class edit in the form" do
    response.should have_tag("form table.edit")
  end
  
  it "should have first and last name fields" do
    response.should have_tag("table.edit input#user_firstname")
    response.should have_tag("table.edit input#user_lastname")
  end
  
  it "should have two address fields" do
    response.should have_tag("table.edit input#user_street")
    response.should have_tag("table.edit input#user_street2")
  end
  
  it "should have a city field" do
    response.should have_tag("table.edit input#user_city")
  end
  
  it "should have a state field" do
    response.should have_tag("table.edit select#user_state_id")
  end
  
  it "should have a zip field" do
    response.should have_tag("table.edit input#user_zip")
  end
  
  it "should have a checkbox for showing info on contact sheet" do
    response.should have_tag("input[type=checkbox]#user_show_contact")
  end
  
  it "should have a submit button" do
    response.should have_tag("form input[type=submit]")
  end
end
