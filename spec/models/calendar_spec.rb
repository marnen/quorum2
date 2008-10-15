require File.dirname(__FILE__) + '/../spec_helper'

describe Calendar do
  before(:each) do
    @calendar = Calendar.new
  end

  it "should be valid" do
    @calendar.should be_valid
  end
end
