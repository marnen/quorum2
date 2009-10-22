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
      Acts::Addressed::ClassMethods.instance_method(:acts_as_addressed).should_not be_nil
    end
    
    describe "effects on model" do
      before :each do
        @base = Class.new
        @base.send :include, Acts::Addressed
        @class = Class.new @base
      end
      
      it "should create an Address aggregation" do
        @class.should_receive(:composed_of).with(:address, :mapping => %w(street street2 city state_id zip coords).collect{|x| [x, x.gsub(/_id$/, '')]})
        @class.acts_as_addressed
      end
    end
  end
end
