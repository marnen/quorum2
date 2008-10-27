require File.dirname(__FILE__) + '/../spec_helper'

describe Calendar do
  before(:each) do
    @calendar = Calendar.new
  end

  it "should return its name for to_s" do
    @calendar.name = "My calendar"
    @calendar.to_s.should == @calendar.name
  end
end

describe Calendar, '(associations)' do
  it "should have many Events" do
    Calendar.reflect_on_association(:events).macro.should == :has_many
  end

  it "should have many Permissions" do
    Calendar.reflect_on_association(:permissions).macro.should == :has_many
  end

  it "should have many Users through Permissions" do
    u = Calendar.reflect_on_association(:users)
    u.macro.should == :has_many
    u.options[:through].should == :permissions
  end
end
