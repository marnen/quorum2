require File.dirname(__FILE__) + '/../spec_helper'

describe EventController, "list" do
  before :each do
    get 'list'
  end
  
  it "should be successful" do
    response.should be_success
  end
  
  it "should get all events, ordered by date" do
    assigns[:events].should == Event.find(:all, :order => :date)
  end
end

=begin
  #Delete these examples and add some real ones
  it "should use EventController" do
    controller.should be_an_instance_of(EventController)
  end


  describe "GET 'list'" do
    it "should be successful" do
      get 'list'
      response.should be_success
    end
  end

  describe "GET 'new'" do
    it "should be successful" do
      get 'new'
      response.should be_success
    end
  end

  describe "GET 'edit'" do
    it "should be successful" do
      get 'edit'
      response.should be_success
    end
  end
=end