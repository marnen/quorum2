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
  
  it "should be composed_of an Address" do
    aggr = User.reflect_on_aggregation(:address)
    aggr.should_not be_nil
    aggr.options[:mapping].should == [%w(street street), %w(street2 street2), %w(city city), %w(state_id state), %w(zip zip), %w(coords coords)]
    state = State.make(:code => 'NY', :country => Country.make(:code => 'US'))
    opts = {:street => '123 Main Street', :street2 => '1st floor', :city => 'Anytown', :zip => 12345, :state => state}
    u = User.new(opts)
    u.address.should == Address.new(opts)
  end
  
  it "should have a writable flag controlling display of personal information on contact list" do
    u = User.new
    u.should respond_to(:show_contact)
    u.should respond_to(:show_contact=)
  end
  
  it "should have country referred through state" do
    state = State.make
    user = User.new
    user.should respond_to(:country)
    user.state = state
    user.country.should == state.country
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
=begin
  it "should require at least one permission" do
    user = users(:marnen)
    user.should be_valid
    Permission.delete(user.permissions.collect{|p| p.id})
    user.reload.should_not be_valid
  end
=end

  it 'should create a user permission for the calendar, when there\'s only one calendar' do
    User.stub!(:current_user).and_return(User.make)
    calendar = Calendar.make
    Calendar.count.should == 1
    user = User.create!(User.plan)
    user.permissions.should_not be_nil
    user.permissions.should_not be_empty
    user.permissions[0].user.should == user
    user.permissions[0].calendar.should == calendar
    user.permissions[0].role.name.should == 'user'
  end
end
  
describe User, "(instance methods)" do
  describe "<=>" do
    it "should be valid" do
      User.new.should respond_to(:<=>)
      User.method(:<=>).arity.should == 1
    end
    
    it "should sort on last name, first name, and e-mail address in that order" do
      attrs = ['Smith', 'John', 'jsmith1@aol.com']
      smith = u(attrs)
      (smith <=> u(['Smith', 'John', 'jsmith2@aol.com'])).should == -1
      (smith <=> u(['Jones', 'Robert', 'rj123@gmail.com'])).should == 1
      (smith <=> u(['Smith', 'Mary', 'aaa@aaa.com'])).should == -1
      (smith <=> u([nil, nil, 'Smitty@aol.com'])).should == -1 # nil-safe
      (smith <=> u(attrs.collect(&:downcase))).should == 0 # not case-sensitive
    end
    
    protected
    def u(array)
      User.new(:lastname => array[0], :firstname => array[1], :email => array[2])
    end
  end
  
  describe "to_s" do
    it "should return firstname or lastname if only one of these is defined, 'firstname lastname' if both are defined, or e-mail address if no name is defined" do
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
    
    it "should take an optional parameter, :first_last or :last_first" do
      @user = User.new
      lambda{@user.to_s}.should_not raise_error
      lambda{@user.to_s :first_last}.should_not raise_error
      lambda{@user.to_s :last_first}.should_not raise_error
    end
    
    describe nil do
      before(:each) do
        @user = User.new(:email => 'foo@bar.com', :firstname => 'f', :lastname => 'l')
      end
      
      it "should return lastname, firstname if :last_first is specified" do
        @user.to_s(:last_first).should == 'l, f'
      end
      
      it "should default to :first_last if no order is specified" do
        @user.to_s.should == @user.to_s(:first_last)
      end
      
      it "should raise an error if format is unrecognized" do
        lambda{@user.to_s :bogus}.should raise_error
      end
    end
  end
  
  describe "activate" do
    it "should be valid" do
      User.make.should respond_to(:activate)
    end
    
    it "should set the active flag to true" do
      u = User.make(:inactive)
      u.activate
      u.active?.should be_true
    end
  end
  
  it "should have a 'single_access_token' property initialized to a string" do
    User.make.single_access_token.should_not be_blank
  end
  
  it "should set single_access_token on save" do
    @u = User.make
    @u.single_access_token = nil
    @u.reload.single_access_token.should_not be_blank
  end
  
  it "should not overwrite single_access_token if already set" do
    @u = User.make
    token = @u.single_access_token
    @u.reload.single_access_token.should == token
  end
  
  it "should properly deal with regenerating single_access_token if it's a duplicate" do
    @one = User.make
    @two = User.make
    token = @two.single_access_token
    @one.single_access_token = token
    # TODO: Does this properly test what's being asserted here?
    @one.reload.single_access_token.should_not == token
  end
  
  describe "reset_password!" do
    it "should be a valid instance method" do
      User.new.should respond_to(:reset_password!)
    end
    
    it "should reset the user's password and password_confirmation to identical strings" do
      old_password = 'old password'
      user = User.make(:password => old_password)
      lambda {user.reset_password!}.should_not raise_error(ActiveRecord::RecordInvalid) # should set password_confirmation
      new_password = user.password
      new_password.should_not == old_password
    end
    
    it "should reset password to a random hex string of length 10 (MD5 digest or similar)" do
      pattern = /^[a-f\d]{10}$/
      user = User.make
      user.reset_password!
      password1 = user.password
      password1.should =~ pattern
      user.reset_password!
      password2 = user.password
      password2.should =~ pattern
      password2.should_not == password1
    end
  end
end

describe User, "(geographical features)" do
  before(:each) do
    @placemark = Geocoding::Placemark.new
    @placemark.stub!(:latlon).and_return([1.0, 2.0])
    Geocoding::Placemark.stub!(:new).and_return(@placemark)
    
    @placemarks = Geocoding::Placemarks.new('Test Placemarks', Geocoding::GEO_SUCCESS)
    @placemarks.stub!(:[]).and_return(@placemark)
    Geocoding::Placemarks.stub!(:new).and_return(@placemarks)
    Geocoding.stub!(:get).and_return(@placemarks)

    @user = User.new(User.plan)
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
  
  it "should clear coords on update" do
    User.stub!(:current_user).and_return(User.make)
    @user.update_attributes(User.plan)
    @user.should_receive(:coords=)
    @user.update_attributes(:name => 'foo')
  end
end

describe User, "(authentication structure)" do
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
  
protected
  def create_user(options = {})
    record = User.make_unsaved({:email => 'quire@example.com', :password => 'quire', :password_confirmation => 'quire'}.merge(options))
    record.save
    record
  end
end
