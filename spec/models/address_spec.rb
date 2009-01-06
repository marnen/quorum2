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
    before(:each) do
      @state = mock_model(State, :code => 'NY', :country => mock_model(Country, :code => 'US'))
    end
    
    it "should set all options passed in on legitimate field keys in a Hash" do
      a = Address.new(:street => '123 Main Street', :street2 => 'Apt. 1', :city => 'Anytown', :state => @state, :zip => '12345')
      a.street.should == '123 Main Street'
      a.street2.should == 'Apt. 1'
      a.city.should == 'Anytown'
      a.state.should == @state
      a.zip.should == '12345'
    end
    
    it "should ignore bogus fields in the constructor" do
      lambda { @a = Address.new(:street => 'real field', :bogus => 'bogus field') }.should_not raise_error
      @a.street.should == 'real field'
      @a.should_not respond_to(:bogus)
    end
    
    it "should accept 5 separate arguments for street, street2, city, state, and zip" do
      street = '123 Main Street'
      street2 = 'Apt. 1'
      city = 'Anytown'
      zip = '12345'
      
      a = Address.new(street, street2, city, @state, zip)
      a.street.should == street
      a.street2.should == street2
      a.city.should == city
      a.state.should == @state
      a.zip.should == zip
    end
    
    it "should treat the state argument as a state_id -- and retrieve a State object -- if it wasn't passed a State object in the first place" do
      ny = mock_model(State, :id => 12, :code => 'NY', :name => 'New York', :country => mock_model(Country, :code => 'US'))
      State.should_receive(:find).with(ny.id).exactly(:once).and_return(ny)
      a = Address.new(:state => ny.id)
      a.state.should == ny
      b = Address.new(:state => ny)
      b.state.should == ny
    end
  end
  
  describe '(methods)' do
    describe '==' do
      it "should only compare value, not object identity" do
        opts = {:street => 'street', :zip => 'zip', :state => mock_model(State)}
        a = Address.new(opts)
        b = Address.new(opts)
        a.should_not equal b # object identity
        a.should == b # value identity
        
        b = opts # Hash, not Address
        a.should_not == b
        
        a = Address.new(opts.update(:street2 => 'street2'))
        a.should_not == b
      end
    end
    
    describe 'country' do
      it "should be a valid instance method" do
        Address.new.should respond_to(:country)
      end
      
      it "should return nil if self.state is nil" do
        Address.new.country.should be_nil
      end
      
      it "should return self.state.country if self.state is not nil" do
        country = mock_model(Country, :name => 'US')
        Address.new(:state => mock_model(State, :country => country)).country.should == country
      end
    end
  end
end
