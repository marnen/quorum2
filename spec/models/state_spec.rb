require File.dirname(__FILE__) + '/../spec_helper'

describe State, "(general properties)" do
  it "should belong to a Country" do
    State.reflect_on_association(:country).macro.should == :belongs_to
  end
end

describe State, "(validations)" do
  before(:each) do
    @state = State.new
    @state.name = "xyz" # arbitrary value
    @state.country_id = 23 # arbitrary value
    @state.code = "AA" # arbitrary value
  end
  
  it "should not be valid without a state code" do
    @state.should be_valid
    @state.code = nil
    @state.should_not be_valid
  end
  
  it "should not be valid without a name" do
    @state.should be_valid
    @state.name = nil
    @state.should_not be_valid
  end
  
  it "should not be valid without a country" do
    @state.should be_valid
    @state.country = nil
    @state.should_not be_valid
  end
end