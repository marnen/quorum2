require File.dirname(__FILE__) + '/../spec_helper'

describe Event, "(general properties)" do
  before(:each) do
  end
  
  it "should belong to a State" do
    Event.reflect_on_association(:state).macro.should == :belongs_to
  end
  
  it "should belong to a Country" do
    pending("should test for :include :country on :state, but I'm not sure how to write that.")
  end
  
  it "should have and belong to many Users" do
    Event.reflect_on_association(:users).macro.should == :has_and_belongs_to_many
  end
end

describe Event, "(validations)" do
  before(:each) do
    @event = Event.new
  end
  
  it "should be invalid if state is nil" do
    @event.should_not be_valid
  end
  
  it "should be valid if state is not nil" do
    @event.state_id = 23 # arbitrary; should be able to use any value
    @event.should be_valid
  end
end
=begin
describe Event, "(geographical features)" do
  before(:each) do
    Geocoding::Placemarks.any_instance.expects(:[]).returns(Geocoding::Placemark.new)
    Geocoding::Placemark.any_instance.stubs(:latlon).returns([1.0, 2.0])
    Geocoding.expects(:get).returns(Geocoding::Placemarks.new('Test Placemarks', Geocoding::GEO_SUCCESS))
    Point::any_instance.stubs(:from_coordinates).returns(true)

    @event = Event.new
  end

  it "should have coords (Point)" do
    @event.should respond_to(:coords)
    @event.coords.should_not be_nil
    @event.coords.should be_a_kind_of(Point)
  end
end
=end