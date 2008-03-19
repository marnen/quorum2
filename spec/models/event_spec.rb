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
    
  it "should have many Commitments" do
    Event.reflect_on_association(:commitments).macro.should == :has_many
  end
  
  it "should have many Users through Commitments" do
    reflection = Event.reflect_on_association(:users)
    reflection.macro.should == :has_many
    reflection.options.should have_key(:through)
    reflection.options[:through].should == :commitments
  end
  
  it "should belong to a User through created_by_id" do
    reflection = Event.reflect_on_association(:created_by)
    reflection.macro.should == :belongs_to
    reflection.options.should have_key(:class_name)
    reflection.options[:class_name].should == "User"
  end
  
  it "should have a country property referred through state" do
    event = Event.new
    event.state = State.new
    event.country.should == event.state.country
  end
  
  it "should have a deleted property" do
    event = Event.new
    event.should respond_to(:deleted)
  end
end

describe Event, "(find_committed)" do
  before(:each) do
    @event = Event.new
    @find = @event.method(:find_committed)
  end
  
  it "should exist with one argument" do
    @event.should respond_to(:find_committed)
    @find.arity.should == 1
  end
  
  it "should get a collection of Users when called with :yes or :no" do
    yes = @find[:yes]
    yes.should be_a_kind_of(Array)
    if !yes[0].nil? then
      yes[0].should be_a_kind_of(User)
    end
    no = @find[:no]
    no.should be_a_kind_of(Array)
    if !no[0].nil? then
      no[0].should be_a_kind_of(User)
    end
  end
end

describe Event, "(validations)" do
  fixtures :users
  
  before(:each) do
    @event = Event.new
    @event.state_id = 23 # arbitrary; should be able to use any value
    @event.city = "x" # arbitrary value
    @event.created_by_id = 34 # arbitrary
    @event.name = "y" # arbitrary
  end
  
  it "should not be valid without a state" do
   @event.should be_valid
   @event.state_id = nil
   @event.should_not be_valid
  end
 
  it "should not be valid without a name" do
   @event.should be_valid
   @event.name = nil
   @event.should_not be_valid
  end
 
=begin
 it "should not be valid without a city" do
   @event.should be_valid
   @event.city = nil
   @event.should_not be_valid
 end
=end

  it "should assign current_user to created_by" do
    @event.created_by_id = nil
    User.should_receive(:current_user).and_return(users(:marnen))
    @event.save!
    @event.created_by.should == users(:marnen)
  end
end

describe Event, "(geographical features)" do
  fixtures :events, :states, :countries
  
  before(:each) do
    Geocoding::Placemarks.any_instance.expects(:[]).returns(Geocoding::Placemark.new)
    Geocoding::Placemark.any_instance.stubs(:latlon).returns([1.0, 2.0])
    Geocoding.expects(:get).returns(Geocoding::Placemarks.new('Test Placemarks', Geocoding::GEO_SUCCESS))
    Point::any_instance.stubs(:from_coordinates).returns(true)

    @event = events(:one)
  end

  it "should have coords (Point)" do
    @event.should respond_to(:coords)
    @event.coords.should_not be_nil
    @event.coords.should be_a_kind_of(Point)
  end
  
  it "should save coords when successfully encoded" do
    @event.should_receive(:save).once
    @event.coords
  end
  
  it "should not save coords when unsuccessfully encoded" do
    Geocoding.stub!(:get).and_return(false)
    @event.should_not_receive(:save)
    @event.coords
  end  
end