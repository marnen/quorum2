require 'spec_helper'

describe "/events/map" do
  before(:each) do
    assign :event, Factory(:event)
  end
  
  it "should render the map in @map" do
    User.stub!(:current_user).and_return(Factory(:user))
    render :file => 'events/map'
    response.should have_selector("#map")
  end
end
