# coding: UTF-8

require 'spec_helper'

describe Commitment, "(general properties)" do
  it "should belong to an Event" do
    Commitment.reflect_on_association(:event).macro.should == :belongs_to
  end

  it "should belong to a User" do
    Commitment.reflect_on_association(:user).macro.should == :belongs_to
  end
end

describe Commitment, "(validations)" do
  let(:commitment) { FactoryGirl.create :commitment, event: FactoryGirl.create(:event), user: FactoryGirl.create(:user) }

  before(:each) { User.delete_all } # TODO: why is this necessary?

  it "should not be valid without an event" do
    commitment.should be_valid
    commitment.event_id = nil
    commitment.should_not be_valid
  end

  it "should not be valid without a user" do
    commitment.should be_valid
    commitment.user_id = nil
    commitment.should_not be_valid
  end
end
