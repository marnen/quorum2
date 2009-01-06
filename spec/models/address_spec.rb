require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Address do
  describe '(fields)' do
    before(:each) do
      @address = Address.new
    end
    
    it "should have two street fields" do
      [:street, :street2].each do |m|
        @address.should respond_to(m)
      end
    end
  end
end
