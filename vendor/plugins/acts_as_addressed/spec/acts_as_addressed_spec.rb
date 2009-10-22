require File.dirname(__FILE__) + '/spec_helper'

describe Acts::Addressed, "inclusion" do
  it "should extend SingletonMethods when module is included" do
    @active_record = Class.new
    @active_record.should_receive(:extend).with(Acts::Addressed::SingletonMethods)
    @active_record.send :include, Acts::Addressed
  end
end

describe Acts::Addressed::SingletonMethods do
  describe "acts_as_addressed" do
    it "should be a valid method" do
      Acts::Addressed::SingletonMethods.instance_method(:acts_as_addressed).should_not be_nil
    end
    
    describe "effects on model" do
      before :each do
        @active_record = Class.new
        @active_record.send :include, Acts::Addressed
        @model = Class.new @active_record
        @model.stub!(:composed_of)
      end
      
      it "should create an Address aggregation" do
        @model.should_receive(:composed_of).with(:address, :mapping => %w(street street2 city state_id zip coords).collect{|x| [x, x.gsub(/_id$/, '')]})
        @model.acts_as_addressed
      end
      
      it "should include InstanceMethods in the model" do
        im = Acts::Addressed::InstanceMethods
        @model.should_receive(:include).with(im)
        @model.acts_as_addressed
      end
    end
  end
end

describe Acts::Addressed::InstanceMethods do
  before :each do
    @active_record = Class.new
    @active_record.send :include, Acts::Addressed
    @model = Class.new @active_record
    @model.stub!(:composed_of)
    @model.acts_as_addressed
    @instance = @model.new
  end
  
  describe "country" do
    it "should be a valid method" do
      Acts::Addressed::InstanceMethods.instance_method(:country).should_not be_nil
    end
    
    it "should proxy from address" do
      @address = mock 'Address'
      @address.should_receive :country
      @instance.should_receive(:address).and_return(@address)
      @instance.country
    end
  end
end
