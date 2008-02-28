require File.dirname(__FILE__) + '/../spec_helper'

describe State do
  before(:each) do
    @state = State.new
  end

  it "should be valid" do
    @state.should be_valid
  end
end
