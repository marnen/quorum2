# coding: UTF-8

require 'spec_helper'

describe "/users/new" do
  before(:each) do
    view.stub :current_user
    render :file => 'users/new'
  end
  
  it "should have a form" do
    rendered.should have_selector("form")
  end
  
  it "should have a table of class edit in the form" do
    rendered.should have_selector("form table.edit")
  end
  
  it "should have first and last name fields" do
    rendered.should have_selector("table.edit input#user_firstname")
    rendered.should have_selector("table.edit input#user_lastname")
  end
  
  it "should have two address fields" do
    rendered.should have_selector("table.edit input#user_street")
    rendered.should have_selector("table.edit input#user_street2")
  end
  
  it "should have a city field" do
    rendered.should have_selector("table.edit input#user_city")
  end
  
  it "should have a state field" do
    rendered.should have_selector("table.edit select#user_state_id")
  end
  
  it "should have a zip field" do
    rendered.should have_selector("table.edit input#user_zip")
  end
  
  it "should have a checkbox for showing info on contact sheet" do
    rendered.should have_selector("input[type=checkbox]#user_show_contact")
  end
  
  it "should have a submit button" do
    rendered.should have_selector("form input[type=submit]")
  end
end
