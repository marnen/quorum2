require File.dirname(__FILE__) + '/../../spec_helper'

require 'acts/addressed/country'

module Acts::Addressed
  describe Country, "(associations)" do
    it "should have many states" do
      assoc = Country.reflect_on_association(:states)
      assoc.should_not be_nil
      assoc.macro.should == :has_many
    end
  end
  
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
end