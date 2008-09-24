require File.dirname(__FILE__) + '/../../spec_helper'

describe "/events/new" do
  fixtures :users, :events
  
  before(:each) do
    login_as :quentin
    assigns[:current_object] = events(:one)
    render 'events/new'
  end
  
  it "should have a form" do
    response.should have_tag("form")
  end
  
  it "should have a table of class edit in the form" do
    response.should have_tag("form table.edit")
  end
  
  it "should have a name field" do
    response.should have_tag("table.edit input#event_name")
  end
  
  it "should have a description field" do
    response.should have_tag("table.edit textarea#event_description")
  end
  
  it "should have a date selector" do
    response.should have_tag("table.edit select#event_date_2i")
  end

  it "should have a site field" do
    response.should have_tag("table.edit input#event_site")
  end
  
  it "should have two address fields" do
    response.should have_tag("table.edit input#event_street")
    response.should have_tag("table.edit input#event_street2")
  end
  
  it "should have a city field" do
    response.should have_tag("table.edit input#event_city")
  end
  
  it "should have a state field" do
    response.should have_tag("table.edit select#event_state_id")
  end
  
  it "should have a zip field" do
    response.should have_tag("table.edit input#event_zip")
  end
  
  it "should have a submit button" do
    response.should have_tag("form input[type=submit]")
  end
  
end