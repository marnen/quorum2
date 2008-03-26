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
  
  it "should have a Role" do
    User.reflect_on_association(:role).macro.should == :belongs_to
  end
  
  it "should have a writable flag controlling display of personal information on contact list" do
    u = User.new
    u.should respond_to(:show_contact)
    u.should respond_to(:show_contact=)
  end
end

describe User, "(validations)" do
  fixtures :users, :roles
  
  it "should require a role" do
    user = users(:marnen)
    user.should be_valid
    user.role_id = nil
    user.should_not be_valid
  end
end
  
describe User, "(instance properties)" do
  before(:each) do
    @user = User.new
  end
  
  it "should have a 'fullname' property returning firstname or lastname if only one of these is defined, 'firstname lastname' if both are defined, or e-mail address if no name is defined" do
    @user.email = 'foo@bar.com' # arbitrary
    @user.fullname.should == @user.email
    @user.firstname = 'f' # arbitrary
    @user.fullname.should == @user.firstname
    @user.firstname = nil
    @user.lastname = 'l' # arbitrary
    @user.fullname.should == @user.lastname
    @user.firstname = 'f'
    @user.fullname.should == @user.firstname << ' ' << @user.lastname
  end
end

describe User, "(geographical features)" do
  fixtures :users, :states, :countries
  
  before(:each) do
    Geocoding::Placemarks.any_instance.expects(:[]).returns(Geocoding::Placemark.new)
    Geocoding::Placemark.any_instance.stubs(:latlon).returns([1.0, 2.0])
    Geocoding.expects(:get).returns(Geocoding::Placemarks.new('Test Placemarks', Geocoding::GEO_SUCCESS))
    Point::any_instance.stubs(:from_coordinates).returns(true)

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
    Geocoding.expects(:get).returns(false)
    @user.should_not_receive(:save)
    @user.coords
  end
end

describe User, "(authentication structure)" do
  fixtures :users

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
    record = User.new({ :email => 'quire@example.com', :password => 'quire', :password_confirmation => 'quire' }.merge(options))
    record.role_id = 1 # arbitrary
    record.save
    record
  end
end
