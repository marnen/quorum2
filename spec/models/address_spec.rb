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
    
    it "should have a city field" do
      @address.should respond_to(:city)
    end
    
    it "should have a state field" do
      @address.should respond_to(:state)
    end

    it "should have a zip field" do
      @address.should respond_to(:zip)
    end
  end
  
  describe '(constructor)' do
    it "should set all options passed in on legitimate fields" do
      state = mock_model(State, :code => 'NY', :country => mock_model(Country, :code => 'US'))
      a = Address.new(:street => '123 Main Street', :street2 => 'Apt. 1', :city => 'Anytown', :state => state, :zip => '12345')
      a.street.should == '123 Main Street'
      a.street2.should == 'Apt. 1'
      a.city.should == 'Anytown'
      a.state.should == state
      a.zip.should == '12345'
    end
    
    it "should ignore bogus fields in the constructor" do
      lambda { @a = Address.new(:street => 'real field', :bogus => 'bogus field') }.should_not raise_error
      @a.street.should == 'real field'
      @a.should_not respond_to(:bogus)
    end
  end
end
