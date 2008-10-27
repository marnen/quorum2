require File.dirname(__FILE__) + '/../spec_helper'

describe Calendar do
  before(:each) do
    @calendar = Calendar.new
  end

  it "should return its name for to_s" do
    @calendar.name = "My calendar"
    @calendar.to_s.should == @calendar.name
  end
end

describe Calendar, '(associations)' do
  it "should have many Events" do
    Calendar.reflect_on_association(:events).macro.should == :has_many
  end

  it "should have many Permissions" do
    Calendar.reflect_on_association(:permissions).macro.should == :has_many
  end

  it "should have many Users through Permissions" do
    u = Calendar.reflect_on_association(:users)
    u.macro.should == :has_many
    u.options[:through].should == :permissions
  end
end

describe Calendar, '(validations)' do
  before(:each) do
    @calendar = Calendar.new(:name => 'Calendar for testing')
  end
  
  it 'should require a name' do
    @calendar.should be_valid
    @calendar.name = nil
    # @calendar.should_not be_valid
  end
  
  it 'should set its creator as admin' do
    @admin = mock_model(Role, :id => 2, :name => 'admin')
    @user = mock_model(User, :id => 15, :name => 'creator')
    User.stub!(:current_user).and_return(@user)

    Role.should_receive(:find_by_name).with('admin').and_return(@admin)
    opts = {:calendar => @calendar, :user => @user, :role => @admin}
    @perm = mock_model(Permission, opts.merge(:null_object => true))
    @perm.should_receive(:[]=).with('calendar_id', anything)
    Permission.should_receive(:create!).with(opts).and_return(@perm)
    
    @calendar.save!
    @calendar.permissions.should == [@perm]
  end
  
  it 'should not create permissions when the calendar is invalid' do
    @calendar.name = nil
    Permission.should_not_receive(:create!)
    begin
      @calendar.save! # will throw an exception, of course
    rescue
    end
  end
end
