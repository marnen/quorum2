# coding: UTF-8

require 'spec_helper'

describe Event, "(general properties)" do
  before(:each) do
  end
  
  it "should act_as_addressed" do
    Event.included_modules.should include(Acts::Addressed::InstanceMethods)
  end
  
  it "should belong to a State" do
    r = Event.reflect_on_association(:state_raw)
    r.macro.should == :belongs_to
    r.options[:class_name].should == 'Acts::Addressed::State'
    r.options[:foreign_key].should == 'state_id'
  end
  
  it "should belong to a Country" do
    pending ":include doesn't seem to be a good idea at all -- must investigate" do
      opts = Event.reflect_on_association(:state).options
      opts.should have_key(:include)
      opts[:include].should == :country
    end
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
    event = Factory :event, :state => Factory(:state)
    event.state.should_not be_nil
    event.country.should == event.state.country
  end
  
  it "should be nil-safe on country" do
    event = Event.new(:state => nil)
    lambda{event.country}.should_not raise_error
  end

  it "should be composed_of an Address" do
    aggr = Event.reflect_on_aggregation(:address)
    aggr.should_not be_nil
    aggr.options[:mapping].should == [%w(street street), %w(street2 street2), %w(city city), %w(state_id state), %w(zip zip), %w(coords coords)]
    state = FactoryGirl.create :state
    opts = {:street => '123 Main Street', :street2 => '1st floor', :city => 'Anytown', :zip => 12345, :state => state}
    e = Event.new(opts)
    e.address.should == Acts::Addressed::Address.new(opts)
  end
  
  it "should have a deleted property" do
    event = Event.new
    event.should respond_to(:deleted)
  end
  
  it "should exclude deleted events on find" do
    undeleted = FactoryGirl.create :event
    begin
      deleted = FactoryGirl.create :event, :deleted => true
    rescue ActiveRecord::RecordNotFound
      # don't worry about it -- since default_scope excludes this record, it won't be found.
    end
    all = Event.find :all
    all.should include(undeleted)
    all.should_not include(deleted)
  end
  
  it "should have a description" do
    event = Event.new
    event.should respond_to(:description)
  end
end

describe Event, "(allow?)" do
  before(:each) do
    @event = FactoryGirl.create :event
    @alien = FactoryGirl.create :user, :permissions => [Factory(:permission)]
    @nonadmin = FactoryGirl.create :user, :permissions => [Factory(:permission, :calendar => @event.calendar)]
    @admin = FactoryGirl.create(:user).tap do |u|
      u.permissions << Factory(:admin_permission, :calendar => @event.calendar, :user => u)
    end
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
    user = Factory(:user).tap do |u|
      u.permissions << Factory(:permission, :user => u, :calendar => @event.calendar, :role => Factory(:role, :name => Faker::Lorem.word))
    end
    User.stub!(:current_user).and_return user
    @event.allow?(:show).should == true

    User.stub!(:current_user).and_return Factory(:user, :permissions => [Factory(:permission, :role => Factory(:role, :name => Faker::Lorem.word))])
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

describe Event, "(change_status!)" do
  before(:each) do
    @event = Factory :event
    @user = Factory :user
  end
  
  it "should be valid" do
    @event.should respond_to(:change_status!)
  end
  
  it "should change the status on the already existing commitment if one exists" do
    commitment = Factory :commitment, :event => @event, :user => @user, :status => true
    id = commitment.id
    [false, nil, true].each do |status|
      @event.change_status!(@user, status)
      commitment = Commitment.find(id)
      commitment.status.should == status
    end
  end
  
  it "should create a new commitment if there isn't one" do
    @event.commitments.find_all_by_user_id(@user.id).should be_empty
    @event.change_status!(@user, nil) # somewhat arbitrary choice of status
    @event.commitments.find_all_by_user_id(@user.id).should_not be_empty
  end
end

describe Event, "(find_committed)" do
  before(:each) do
    @event = Factory :event
    @find = @event.method(:find_committed)
  end
  
  it "should exist with one argument" do
    @event.should respond_to(:find_committed)
    @find.arity.should == 1
  end
  
  it "should get a collection of Users when called with :yes or :no" do
    @attending = Factory(:user).tap do |u|
      u.commitments << Factory(:commitment, :user => u, :event => @event, :status => true)
    end
    @not_attending = Factory(:user).tap do |u|
      u.commitments << Factory(:commitment, :user => u, :event => @event, :status => false)
    end
    @find[:yes].should == [@attending]
    @find[:no].should == [@not_attending]
  end
  
  it 'should sort the Users on lastname or, failing that, email' do
    [true, false].each do |status|  
      a = Factory :user, :lastname => 'a'
      b = Factory :user, :email => 'b@b.com', :lastname => nil
      c = Factory :user, :lastname => 'c'
      users = [c, a, b]
      users.each do |u|
        u.commitments << Factory(:commitment, :user => u, :event => @event, :status => status)
      end
  
      @find[status ? :yes : :no].should == [a, b, c]
      
      users.each do |u|
        u.destroy
      end
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
    user = Factory :user
    User.stub!(:current_user).and_return user
    @event.created_by_id = nil
    @event.save!
    @event.created_by.should == user
  end
  
  it "should not try to set created_by if there's no current user" do
    [false, :false].each do |v|
      User.stub!(:current_user).and_return(v)
      @event.created_by_id = nil
      @event.should_not_receive(:created_by=)
      @event.save!
    end
  end
end

describe Event, "(geographical features)" do
  before(:each) do
    @placemark = Geocoding::Placemark.new
    @placemark.stub!(:latlon).and_return([1.0, 2.0])
    Geocoding::Placemark.stub!(:new).and_return(@placemark)
    
    # TODO: Use Webmock here.
    @placemarks = Geocoding::Placemarks.new('Test Placemarks', Geocoding::GEO_SUCCESS)
    @placemarks.stub!(:[]).and_return(@placemark)
    Geocoding::Placemarks.stub!(:new).and_return(@placemarks)
    Geocoding.stub!(:get).and_return(@placemarks)

    @event = Factory.build :event
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
    User.stub!(:current_user).and_return(Factory :user)
    @event.update_attributes(Factory.attributes_for :event)
    @event.should_receive(:coords=)
    @event.update_attributes(:name => 'foo')
    # @event.should_not_receive(:coords=)
    # @event.update_attributes(nil)
  end
end