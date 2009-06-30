require File.dirname(__FILE__) + '/../spec_helper'

describe Search do
  before(:each) do
    @hash = {:a => 1, :b => 2}
  end
  
  it "should be usable on a Hash" do
    lambda{@hash.extend(Search)}.should_not raise_error
  end
  
  it "should be able to extend nil" do
    lambda{nil.extend(Search)}.should_not raise_error
  end
  
  it "should support method-style access to hash keys" do
    @hash.extend(Search)
    @hash.a.should == @hash[:a]
    @hash.b.should == @hash[:b]
  end
  
  it "should construct dates from hash elements" do
    year = '2008'
    month = '7'
    day = '4'
    @hash.extend(Search)
    @hash.update(:'foo_date(1i)' => year, :'foo_date(2i)' => month, :'foo_date(3i)' => day)
    @hash.foo_date.should == Date.civil(year.to_i, month.to_i, day.to_i)
  end
  
  describe '(date presets)' do
    before(:each) do
      from_year = '1919'
      from_month = '7'
      from_day = '4'
      @from_date = Date.civil(from_year.to_i, from_month.to_i, from_day.to_i)
      @hash = {:'from_date(1i)' => from_year, :'from_date(2i)' => from_month, :'from_date(3i)' => from_day}.extend(Search)
    end
    
    it 'should return current date if preset is "today"' do
      today = Time.zone.today
      Time.zone.stub!(:today).and_return today
      @hash[:from_date_preset] = 'today'
      @hash.from_date.should == today
    end
    
    it 'should return an early date if preset is "earliest"' do
      earliest = Date.civil(1, 1, 1)
      @hash[:from_date_preset] = 'earliest'
      @hash.from_date.should == earliest
    end
    
    it 'should return nil if preset is "latest"' do
      @hash[:from_date_preset] = 'latest'
      lambda{@hash.from_date}.should_not raise_error
      @hash.from_date.should be_nil
    end
    
    it 'should return the date in the appropriate 3 elements if preset is "other" or blank' do
      [nil, '', 'other'].each do |x|
        @hash[:from_date_preset] = x
        @hash.from_date.should == @from_date
      end
    end
  end
end
