# coding: UTF-8

require 'spec_helper'

describe Acts::Addressed, "inclusion" do
  it "should extend SingletonMethods when module is included" do
    @active_record = ActiveRecord::Base
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
        @active_record = ActiveRecord::Base
        @active_record.send :include, Acts::Addressed
        @model = Class.new @active_record
      end

      it "should create a State association" do
        @model.should_receive(:belongs_to).with(:state_raw, :class_name => "Acts::Addressed::State", :foreign_key => 'state_id')
      end

      it "should create an Address aggregation" do
        @model.should_receive(:composed_of).with(:address, :class_name => "Acts::Addressed::Address", :mapping => %w(street street2 city state_id zip coords).collect{|x| [x, x.gsub(/_id$/, '')]})
      end

      it "should include InstanceMethods in the model" do
        im = Acts::Addressed::InstanceMethods
        @model.should_receive(:include).with(im)

      end

      after :each do
        @model.acts_as_addressed
      end
    end
  end
end

describe Acts::Addressed::InstanceMethods do
  before :each do
    ActiveRecord::Base.send :include, Acts::Addressed
    @model = Class.new ActiveRecord::Base
    @model.table_name = 'dummies'
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
