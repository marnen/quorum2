require File.dirname(__FILE__) + '/../spec_helper'

describe UserSessionsController do
  it 'logins and redirects' do
    user = User.make
    post :create, :email => user.email, :password => user.password
    session[:user_id].should_not be_nil
    response.should be_redirect
  end
  
  it 'fails login and does not redirect' do
    post :create, :email => 'quentin@example.com', :password => 'bad password'
    session[:user_id].should be_nil
    response.should be_success
  end

  it 'logs out' do
    login_as User.make
    get :destroy
    session[:user_id].should be_nil
    response.should be_redirect
  end

  it 'remembers me' do
    user = User.make
    post :create, :email => user.email, :password => user.password, :remember_me => "1"
    response.cookies["auth_token"].should_not be_nil
  end
  
  it 'does not remember me' do
    user = User.make
    post :create, :email => user.email, :password => user.password, :remember_me => "0"
    response.cookies["auth_token"].should be_nil
  end

  it 'deletes token on logout' do
    login_as User.make
    get :destroy
    response.cookies["auth_token"].should be_blank
  end

  it 'logs in with cookie' do
    user = User.make
    user.remember_me
    request.cookies["auth_token"] = cookie_for(user)
    get :new
    controller.send(:logged_in?).should be_true
  end
  
  it 'fails expired cookie login' do
    user = User.make
    user.remember_me
    user.update_attribute :remember_token_expires_at, 5.minutes.ago
    request.cookies["auth_token"] = cookie_for(user)
    get :new
    controller.send(:logged_in?).should_not be_true
  end
  
  it 'fails cookie login' do
    User.make.remember_me
    request.cookies["auth_token"] = auth_token('invalid_auth_token')
    get :new
    controller.send(:logged_in?).should_not be_true
  end

  def auth_token(token)
    CGI::Cookie.new('name' => 'auth_token', 'value' => token)
  end
    
  def cookie_for(user)
    auth_token user.remember_token
  end
end

describe UserSessionsController, 'new (login)' do
  before(:each) do
    get :new
  end
  
  it "should set @page_title" do
    assigns[:page_title].should_not be_nil
  end
  
  it "should render new template" do
    response.should render_template :new
  end
end
