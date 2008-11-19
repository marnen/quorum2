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
end
