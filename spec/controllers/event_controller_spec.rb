require File.dirname(__FILE__) + '/../spec_helper'

describe EventController, "list" do
  fixtures :users
  
  before(:each) do
    login_as(:quentin)
  end
  
  it "should be successful" do
   get 'list'
   response.should be_success
  end
 
  it "should set the page_title" do
    get :list
    assigns[:page_title].should_not be_nil
  end
  
  it "should get all events, with distance, ordered by date" do
    Event.should_receive(:find).with(:all, :order => :date).once
    get 'list'
  end
end

describe EventController, "change_status" do
  fixtures :users, :events, :commitments
  
  before(:each) do
    login_as :quentin
  end
  
  it "should change attendance status for current user if called with a non-nil event id" do
    event = events(:one)
    commitment = commitments(:one)
    id = event.id
    status = :yes # could also be :no or :maybe
    Event.should_receive(:find_by_id).with(id.to_s).once.and_return(event)
    event.commitments.should_receive(:find_or_create_by_user_id).with(users(:quentin).id).once.and_return(commitment)
    commitment.should_receive(:status=).with(true).once.and_return(true)
    commitment.should_receive(:save!).once.and_return(true)
    get "change_status", :id => id, :status => status
  end
  
  it "should redirect to list" do
    get 'change_status'
    response.should redirect_to(:action => :list)
  end
end

describe EventController, "new" do
  fixtures :users
  
  before(:each) do
    login_as :quentin
    get :new
  end
  
  it "should require login" do
    pending "need to figure out how to write this"
  end
  
  it "should be successful" do
   response.should be_success
  end
 
  it "should set the page_title" do
    assigns[:page_title].should_not be_nil
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