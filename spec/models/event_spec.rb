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
  
  it "should have a description" do
    event = Event.new
    event.should respond_to(:description)
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

describe Event, "(hide)" do
  before(:each) do
    @event = Event.new
  end
  
  it "should set deleted to true" do
    @event.deleted.should_not == true
    @event.hide
    @event.deleted.should == true
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
    @placemark = Geocoding::Placemark.new
    @placemark.stub!(:latlon).and_return([1.0, 2.0])
    Geocoding::Placemark.stub!(:new).and_return(@placemark)
    
    @placemarks = Geocoding::Placemarks.new('Test Placemarks', Geocoding::GEO_SUCCESS)
    @placemarks.stub!(:[]).and_return(@placemark)
    Geocoding::Placemarks.stub!(:new).and_return(@placemarks)
    Geocoding.stub!(:get).and_return(@placemarks)
    Point.stub!(:from_coordinates).and_return(mock_model(Point))

    @event = events(:one)
  end
  
  it "should create a string for the geocodable address parts" do
    @event.should respond_to(:address_for_geocoding)
    addr = @event.address_for_geocoding
    addr.should == "#{@event.street}, #{@event.city}, #{@event.state.code}, #{@event.zip}, #{@event.country.code}"
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
    Geocoding.should_receive(:get).and_return(false)
    @event.should_not_receive(:save)
    @event.coords
  end  
end