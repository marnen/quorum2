require File.dirname(__FILE__) + '/../../spec_helper'

describe "/events/map" do
  fixtures :events, :states, :countries
  
  before(:each) do
    assigns[:event] = events(:one)
  end
  
  it "should render the map in @map" do
    address = Address.new
    address.should_receive(:to_s).with(:geo).and_return('Arbitrary Address, Somewhere, NY, US')
    User.stub!(:current_user).and_return(mock_model(User, :address => address ))
    render 'events/map'
    response.should have_tag("#map")
  end
end
