require File.dirname(__FILE__) + '/spec_helper'

describe Acts::Addressed, "inclusion" do
  it "should include ClassMethods" do
    @class = Class.new
    @class.should_receive(:extend).with(Acts::Addressed::ClassMethods)
    @class.send :include, Acts::Addressed
  end
end

describe Acts::Addressed::ClassMethods do
  describe "acts_as_addressed" do
    it "should be a valid method" do
      
    end
  end
end
