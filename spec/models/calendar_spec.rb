require File.dirname(__FILE__) + '/../spec_helper'

describe Calendar do
  before(:each) do
    @calendar = Calendar.new
  end

  it "should be valid" do
    @calendar.should be_valid
  end
  
  it "should return its name for to_s" do
    @calendar.name = "My calendar"
    @calendar.to_s.should == @calendar.name
  end
end
