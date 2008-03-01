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
end
  
describe User, "(validations)" do
  before(:each) do
    @user = User.new
    @user.email = "foo@bar.com" # arbitrary value
    @user.md5_password = "0123456789abcdef0123456789abcdef" # arbitrary 32-byte string
    @user
  end

  it "should not be valid without an e-mail address" do
    @user.should be_valid
    @user.email = nil
    @user.should_not be_valid
  end
  
  it "should not be valid without a password hash of length exactly 32" do
    @user.should be_valid
    @user.md5_password <<= "0" # length 33
    @user.should_not be_valid
    @user.md5_password = nil
    @user.should_not be_valid
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
