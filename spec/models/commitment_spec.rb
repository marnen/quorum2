require File.dirname(__FILE__) + '/../spec_helper'

describe Commitment, "(general properties)" do
  it "should belong to an Event" do
    Commitment.reflect_on_association(:event).macro.should == :belongs_to
  end
  
  it "should belong to a User" do
    Commitment.reflect_on_association(:user).macro.should == :belongs_to
  end
end

describe Commitment, "(validations)" do
  before(:each) do
    @commitment = Commitment.new
    @commitment.event_id = 1 # arbitrary
    @commitment.user_id = 5 # arbitrary
  end

  it "should not be valid without an event" do
    @commitment.should be_valid
    @commitment.event_id = nil
    @commitment.should_not be_valid
  end

  it "should not be valid without a user" do
    @commitment.should be_valid
    @commitment.user_id = nil
    @commitment.should_not be_valid
  end
end
