require File.dirname(__FILE__) + '/../spec_helper'

describe User, "(general properties)" do
  before(:each) do
  end
  
  it "should belong to a State" do
    User.reflect_on_association(:state).macro.should == :belongs_to
  end
  
  it "should have many Commitments" do
    User.reflect_on_association(:commitments).macro.should == :has_many
  end
  
  it "should have many Events through Commitments" do
    reflection = User.reflect_on_association(:events)
    reflection.macro.should == :has_many
    reflection.options.should have_key(:through)
    reflection.options[:through].should == :commitments
  end
  
  it "should have many Permissions" do
    User.reflect_on_association(:permissions).macro.should == :has_many
  end
  
  it "should have many Calendars through Permissions" do
    reflection = User.reflect_on_association(:calendars)
    reflection.macro.should == :has_many
    reflection.options.should have_key(:through)
    reflection.options[:through].should == :permissions
  end
  
  it "should have a writable flag controlling display of personal information on contact list" do
    u = User.new
    u.should respond_to(:show_contact)
    u.should respond_to(:show_contact=)
  end
  
  it "should have country referred through state" do
    country = mock_model(Country, :name => 'Ruritania', :code => 'RU')
    state = mock_model(State, :name => 'Federal District', :country => country)
    user = User.new
    user.should respond_to(:country)
    user.state = state
    user.country.should == user.state.country
  end
  
end

describe User, "(admin?)" do
  before(:each) do
    @admin = mock_model(Role, :name => 'admin')
    @user = mock_model(Role, :name => 'user')
    @two = mock_model(Permission, :role => @admin, :calendar => mock_model(Calendar, :id => 2, :name => 'Calendar 2'))
  end
  
  it "should return false if user has no admin roles" do
    @permissions = [mock_model(Permission, :role => @user, :calendar => mock_model(Calendar, :id => 1, :name => 'Calendar 1')), mock_model(Permission, :role => @user, :calendar => mock_model(Calendar, :id => 2, :name => 'Calendar 2'))]
    @permissions.stub!(:find_by_role_id).and_return(nil)
    u = User.new
    u.permissions << @permissions
    u.admin?.should == false
  end
  
  it "should return true if user has at least one admin role" do
    @permissions = [mock_model(Permission, :role => @user, :calendar => mock_model(Calendar, :id => 1, :name => 'Calendar 1')), @two]
    u = User.new
    u.permissions << @permissions
    u.permissions.stub!(:find_by_role_id).and_return(@two)
    u.admin?.should == true
  end
end

describe User, "(validations)" do
  fixtures :users, :roles, :calendars, :permissions
  
=begin
  it "should require at least one permission" do
    user = users(:marnen)
    user.should be_valid
    Permission.delete(user.permissions.collect{|p| p.id})
    user.reload.should_not be_valid
  end
=end

  it 'should create a user permission for the calendar, when there\'s only one calendar' do
    Calendar.delete(calendars(:two).id) # so we only have one calendar
    Calendar.count.should == 1
    user = User.new(:email => 'johndoe@example.com', :password => 'foo', :password_confirmation => 'foo')
    user.save!
    user.permissions.should_not be_nil
    user.permissions.should_not be_empty
    user.permissions[0].user.should == user
    user.permissions[0].calendar.should == calendars(:one)
    user.permissions[0].role.should == roles(:user)
  end
end
  
describe User, "(instance properties)" do
  fixtures :users
  
  it "should have a 'to_s' property returning firstname or lastname if only one of these is defined, 'firstname lastname' if both are defined, or e-mail address if no name is defined" do
    @user = User.new
    @user.email = 'foo@bar.com' # arbitrary
    @user.to_s.should == @user.email
    @user.firstname = 'f' # arbitrary
    @user.to_s.should == @user.firstname
    @user.firstname = nil
    @user.lastname = 'l' # arbitrary
    @user.to_s.should == @user.lastname
    @user.firstname = 'f'
    @user.to_s.should == @user.firstname << ' ' << @user.lastname
  end
  
  it "should have a 'feed_key' property initialized to a 32-character string" do
    User.find(:first).feed_key.length.should == 32
  end
  
  it "should set feed_key on save" do
    @u = User.find(:first)
    @u.feed_key = nil
    @u.reload.feed_key.length.should == 32
  end
  
  it "should not overwrite feed_key if already set" do
    @u = User.find(:first)
    fk = @u.feed_key
    @u.reload.feed_key.should == fk
  end
  
  it "should properly deal with regenerating feed_key if it's a duplicate" do
    @users = User.find(:all)
    @one = @users[0]
    @two = @users[1]
    fk = @two.feed_key
    @one.feed_key = fk
    @one.reload.feed_key.should_not == fk

  end
end

describe User, "(geographical features)" do
  fixtures :users, :states, :countries
  
  before(:each) do
    @placemark = Geocoding::Placemark.new
    @placemark.stub!(:latlon).and_return([1.0, 2.0])
    Geocoding::Placemark.stub!(:new).and_return(@placemark)
    
    @placemarks = Geocoding::Placemarks.new('Test Placemarks', Geocoding::GEO_SUCCESS)
    @placemarks.stub!(:[]).and_return(@placemark)
    Geocoding::Placemarks.stub!(:new).and_return(@placemarks)
    Geocoding.stub!(:get).and_return(@placemarks)
    Point.stub!(:from_coordinates).and_return(mock_model(Point))

    @user = users(:marnen)
  end
  
  it "should save coords when successfully encoded" do
    @user.should_receive(:save).once
    @user.coords
  end

  it "should have coords (Point)" do
    @user.should respond_to(:coords)
    @user.coords.should_not be_nil
    @user.coords.should be_a_kind_of(Point)
  end
  
  it "should not save coords when unsuccessfully encoded" do
    Geocoding.should_receive(:get).and_return(false)
    @user.should_not_receive(:save)
    @user.coords
  end
end

describe User, "(authentication structure)" do
  fixtures :users, :roles, :permissions

=begin
  describe 'being created' do
    before do
      @user = nil
      @creating_user = lambda do
        @user = create_user
        violated "#{@user.errors.full_messages.to_sentence}" if @user.new_record?
      end
    end
    
    it 'increments User#count' do
      @creating_user.should change(User, :count).by(1)
    end

    it 'initializes #activation_code' do
      @creating_user.call
      @user.reload.activation_code.should_not be_nil
    end
  end
=end

  it 'requires password' do
    lambda do
      u = create_user(:password => nil)
      u.errors.on(:password).should_not be_nil
    end.should_not change(User, :count)
  end

  it 'requires password confirmation' do
    lambda do
      u = create_user(:password_confirmation => nil)
      u.errors.on(:password_confirmation).should_not be_nil
    end.should_not change(User, :count)
  end

  it 'requires email' do
    lambda do
      u = create_user(:email => nil)
      u.errors.on(:email).should_not be_nil
    end.should_not change(User, :count)
  end

  it 'resets password' do
    users(:quentin).update_attributes(:password => 'new password', :password_confirmation => 'new password')
    User.authenticate('quentin@example.com', 'new password').should == users(:quentin)
  end

  it 'does not rehash password' do
    users(:quentin).update_attributes(:email => 'quentin2@example.com')
    User.authenticate('quentin2@example.com', 'test').should == users(:quentin)
  end

  it 'authenticates user' do
    User.authenticate('quentin@example.com', 'test').should == users(:quentin)
  end

  it 'sets remember token' do
    users(:quentin).remember_me
    users(:quentin).remember_token.should_not be_nil
    users(:quentin).remember_token_expires_at.should_not be_nil
  end

  it 'unsets remember token' do
    users(:quentin).remember_me
    users(:quentin).remember_token.should_not be_nil
    users(:quentin).forget_me
    users(:quentin).remember_token.should be_nil
  end

  it 'remembers me for one week' do
    before = 1.week.from_now.utc
    users(:quentin).remember_me_for 1.week
    after = 1.week.from_now.utc
    users(:quentin).remember_token.should_not be_nil
    users(:quentin).remember_token_expires_at.should_not be_nil
    users(:quentin).remember_token_expires_at.between?(before, after).should be_true
  end

  it 'remembers me until one week' do
    time = 1.week.from_now.utc
    users(:quentin).remember_me_until time
    users(:quentin).remember_token.should_not be_nil
    users(:quentin).remember_token_expires_at.should_not be_nil
    users(:quentin).remember_token_expires_at.should == time
  end

  it 'remembers me default two weeks' do
    before = 2.weeks.from_now.utc
    users(:quentin).remember_me
    after = 2.weeks.from_now.utc
    users(:quentin).remember_token.should_not be_nil
    users(:quentin).remember_token_expires_at.should_not be_nil
    users(:quentin).remember_token_expires_at.between?(before, after).should be_true
  end

protected
  def create_user(options = {})
    record = User.new({ :id => 1, :email => 'quire@example.com', :password => 'quire', :password_confirmation => 'quire' }.merge(options))
    record.save
    record
  end
end
