require File.dirname(__FILE__) + '/../spec_helper'

describe Country, "(validations)" do
  before(:each) do
    @country = Country.new
    @country.code = "AA" # arbitrary value of length 2
    @country.name = "x" # arbitrary value
  end

  it "should not be valid without a code" do
    @country.should be_valid
    @country.code = nil
    @country.should_not be_valid
  end
  
  it "should not be valid unless length of code is exactly 2" do
    @country.should be_valid
    @country.code = "ABC" # length 3
    @country.should_not be_valid
    @country.code = "A" # length 1
    @country.should_not be_valid
  end

  it "should not be valid without a name" do
    @country.should be_valid
    @country.name = nil
    @country.should_not be_valid
  end
end
