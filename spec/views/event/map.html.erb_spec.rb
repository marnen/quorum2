require File.dirname(__FILE__) + '/../../spec_helper'

describe "/event/map" do
  fixtures :events, :states, :countries
  
  before(:each) do
    assigns[:event] = events(:one)
  end
  
  it "should render the map in @map" do
    render 'event/map'
    response.should have_tag("#map")
  end
end
