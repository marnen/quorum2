# coding: UTF-8

require 'spec_helper'

describe UsersController do


# Uncomment this spec when we set up e-mail activation.
=begin
  it 'signs up user with activation code' do
    create_user
    assigns(:user).activation_code.should_not be_nil
  end
=end

  it 'activates user' do
    pending "meaningless until we start doing activation" do
      email = 'aaron@example.com'
      password = 'test'
      aaron = FactoryGirl.create :inactive_user, :email => email, :password => password
      User.authenticate(email, password).should be_nil
      get :activate, :activation_code => aaron.activation_code
      response.should redirect_to('/login')
      flash[:notice].should_not be_nil
      User.authenticate(email, password).should == aaron
    end
  end

  it 'does not activate user without key' do
    pending "meaningless until we start doing activation" do
      get :activate
      flash[:notice].should be_nil
    end
  end

  it 'does not activate user with blank key' do
    pending "meaningless until we start doing activation" do
      get :activate, :activation_code => ''
      flash[:notice].should be_nil
    end
  end

  def create_user(options = {})
    post :create, :user => { :login => 'quire', :email => 'quire@example.com',
    :password => 'quire', :password_confirmation => 'quire', :permissions => [mock_model(Permission)] }.merge(options)
  end
end

describe UsersController, "edit" do
 before(:each) do
    @user = FactoryGirl.create :user
    UserSession.create @user
    get :edit
  end

  it "should reuse the 'new' form" do
    response.should render_template :new
  end

  it "should get the current user" do
    assigns[:user].should == User.current_user
  end

  it "should not require password validation if both password fields are nil" do
    test_user = FactoryGirl.create :user
    my_attr = test_user.attributes
    my_attr[:password] = nil
    my_attr[:password_confirmation] = nil
    User.stub!(:current_user).and_return(test_user)
    post :edit, :user => my_attr
    test_user.errors.should be_empty
  end

  it "should validate password if at least one password field is supplied" do
    pending "could this ever have worked?!?" do
      my_attr = @user.attributes
      @user.password = 'a'
      @user.password_confirmation = nil
      my_attr.should_not be_nil
      post :edit, @user
      @user.errors.should_not be_empty

      @user = FactoryGirl.create :user
      UserSession.create @user
      get :edit
      my_attr = @user.attributes
      my_attr[:password] = nil
      my_attr[:password_confirmation] = 'a'
      my_attr.should_not be_nil
      post :edit, :user => my_attr
      @user.errors.should_not be_empty
    end
  end

  it "should set coords to nil" do
    post :edit, :user => @user.attributes
    pending "Can this really work? Won't coords just be set as soon as it's called?" do
      @user.coords.should be_nil
    end
  end
end

describe UsersController, '(regenerate_key)' do
  before(:each) do
    request.env['HTTP_REFERER'] = 'http://test.host/referer' # so redirect_to :back works
    # controller.stub!(:require_user).and_return(true)
  end

  it "should be a valid action" do
    UserSession.create FactoryGirl.create(:user)
    get :regenerate_key
    response.should redirect_to(:back)
  end

  it "should reset the current user's single_access_token" do
    @user = FactoryGirl.create :user
    token = @user.single_access_token
    UserSession.create @current_user
    get :regenerate_key
    User.find(UserSession.find.record.id).single_access_token.should_not == token
  end

  it 'should set flash[:notice] on success' do
    UserSession.create FactoryGirl.create(:user)
    get :regenerate_key
    flash[:notice].should_not be_nil
  end

  it 'should set flash[:error] on failure' do
    pending "does Authlogic handle errors and/or authentication strangely?" do
      @current_user = FactoryGirl.create :user
      @current_user.should_receive(:save!).and_raise(ActiveRecord::RecordInvalid.new(@current_user))
      UserSession.create @current_user
      get :regenerate_key
      flash[:error].should_not be_nil
    end
  end
end

describe UsersController, '(reset)' do
  render_views

  before(:each) do
    get :reset
  end

  it "should be a valid action" do
    response.should be_success
  end

  it "should display a form asking for e-mail address, with a submit button" do
    response.body.should have_selector('input[type=text]')
    response.body.should have_selector('input[type=submit]')
  end

  it "should set the page title" do
    assigns[:page_title].should_not be_blank
  end
end

describe UsersController, '(reset/POST)' do
  render_views

  it "should give an error message if e-mail isn't valid" do
    User.should_receive(:find_by_email).and_return(nil)
    post :reset, :email => 'someone@example.com'
    flash[:error].should_not be_nil
  end

  it "should reset password if e-mail is valid" do
    @user = FactoryGirl.create :user
    @user.should_receive(:reset_password!).and_return(true)
    User.should_receive(:find_by_email).and_return(@user)
    reset = mock('Mail::Message')
    UserMailer.should_receive(:reset).with(@user).at_least(:once).and_return(reset)
    reset.should_receive :deliver
    post :reset, :email => @user.email
    flash[:error].should be_nil
    flash[:notice].should_not be_nil
  end
end