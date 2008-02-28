require File.dirname(__FILE__) + '/../spec_helper'

describe Country do
  before(:each) do
    @country = Country.new
  end

  it "should be valid" do
    @country.should be_valid
  end
end
