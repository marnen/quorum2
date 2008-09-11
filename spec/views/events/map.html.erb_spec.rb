require File.dirname(__FILE__) + '/../../spec_helper'

describe "/event/map" do
  fixtures :events, :states, :countries
  
  before(:each) do
    assigns[:event] = events(:one)
  end
  
  it "should render the map in @map" do
    User.stub!(:current_user).and_return(mock_model(User, :address_for_geocoding => 'Arbitrary Address, Somewhere, NY, US'))
    render 'event/map'
    response.should have_tag("#map")
  end
end
