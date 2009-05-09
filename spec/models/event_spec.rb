require File.dirname(__FILE__) + '/../spec_helper'

describe Event, "(general properties)" do
  before(:each) do
  end
  
  it "should belong to a State" do
    Event.reflect_on_association(:state).macro.should == :belongs_to
  end
  
  it "should belong to a Country" do
    opts = Event.reflect_on_association(:state).options
    opts.should have_key(:include)
    opts[:include].should == :country
  end
    
  it "should belong to a Calendar" do
    Event.reflect_on_association(:calendar).macro.should == :belongs_to
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
  
  it "should be composed_of an Address" do
    aggr = Event.reflect_on_aggregation(:address)
    aggr.should_not be_nil
    aggr.options[:mapping].should == [%w(street street), %w(street2 street2), %w(city city), %w(state_id state), %w(zip zip), %w(coords coords)]
    state = State.make(:code => 'NY', :country => Country.make(:code => 'US'))
    a = Address.new
    Address.should_receive(:new).and_return(a)
    e = Event.new(:street => '123 Main Street', :street2 => '1st floor', :city => 'Anytown', :zip => 12345, :state => state)
    e.address.should == a
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

describe Event, "(allow?)" do
  before(:each) do
    @event = Event.new(:calendar => mock_model(Calendar, :id => 27))
    @alien = User.make{|u| u.permissions.make(:calendar => mock_model(Calendar, :id => 999))}
    @nonadmin = User.make{|u| u.permissions.make(:calendar => @event.calendar)}
    @admin = User.make{|u| u.permissions.make(:calendar => @event.calendar, :role => Role.make(:admin))}
  end
  
  it "should exist with one argument" do
    @event.should respond_to(:allow?)
    @event.method(:allow?).arity.should == 1
  end
  
  it "should return true for :delete iff current user has a role of admin for the event's calendar, false otherwise" do
    User.stub!(:current_user).and_return(@alien)
    @event.allow?(:delete).should == false
    User.stub!(:current_user).and_return(@admin)
    @event.allow?(:delete).should == true
  end
  
  it "should return true for :edit iff current user has a role of admin for the event's calendar or created the event" do
    @event.created_by = @nonadmin
    User.stub!(:current_user).and_return(@nonadmin)
    @event.allow?(:edit).should == true
    User.stub!(:current_user).and_return(@admin)
    @event.allow?(:edit).should == true
  end
  
  it "should return true for :show iff current user has any role for the event's calendar" do
    User.stub!(:current_user).and_return(User.make{|u| u.permissions.make(:calendar => @event.calendar, :role => Role.make(:name => 'anything'))})
    @event.allow?(:show).should == true

    User.stub!(:current_user).and_return(User.make{|u| u.permissions.make(:calendar => mock_model(Calendar, :id => 37), :role => Role.make(:name => 'anything'))})
    @event.allow?(:show).should == false
  end
  
  it "should return nil for any operation if current user is not a User object" do
    User.stub!(:current_user).and_return('bogus value')
    @event.allow?(:edit).should be_nil
  end
  
  it "should return nil for any operation it doesn't know about" do
    User.stub!(:current_user).and_return(@admin)
    
    @event.allow?(:foobar).should be_nil
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
  
  it 'should sort the Users on lastname or, failing that, email' do
    @array = []
    @array.should_receive(:sort).twice # need to figure out a way to specify the sort block
    @temp = mock('temp', :collect => @array, :null_object => true)
    @event.should_receive(:commitments).twice.and_return(mock('commitments', :clone => @temp))
    @find[:yes]
    @find[:no]
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
  before(:each) do
    @event = Event.new
    @event.state_id = 23 # arbitrary; should be able to use any value
    @event.city = "x" # arbitrary value
    @event.created_by_id = 34 # arbitrary
    @event.name = "y" # arbitrary
    @event.calendar_id = 'abc' # arbitrary
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
 
  it "should not be valid without a calendar" do
   @event.should be_valid
   @event.calendar_id = nil
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
    user = User.make
    User.stub!(:current_user).and_return user
    @event.created_by_id = nil
    @event.save!
    @event.created_by.should == user
  end
end

describe Event, "(geographical features)" do
  before(:each) do
    @placemark = Geocoding::Placemark.new
    @placemark.stub!(:latlon).and_return([1.0, 2.0])
    Geocoding::Placemark.stub!(:new).and_return(@placemark)
    
    @placemarks = Geocoding::Placemarks.new('Test Placemarks', Geocoding::GEO_SUCCESS)
    @placemarks.stub!(:[]).and_return(@placemark)
    Geocoding::Placemarks.stub!(:new).and_return(@placemarks)
    Geocoding.stub!(:get).and_return(@placemarks)
    Point.stub!(:from_coordinates).and_return(mock_model(Point))

    @event = Event.new
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
  
  it "should clear coords on update" do
    User.stub!(:current_user).and_return(User.make)
    @event.update_attributes(Event.plan)
    @event.should_receive(:coords=)
    @event.update_attributes(:name => 'foo')
    # @event.should_not_receive(:coords=)
    # @event.update_attributes(nil)
  end
end