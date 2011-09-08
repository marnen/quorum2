require 'spec_helper'

describe UserSessionsController do
  it 'logins and redirects' do
    user = FactoryGirl.create :user
    post :create, :user_session => {:email => user.email, :password => user.password}
    UserSession.find.should_not be_nil
    response.should be_redirect
  end
  
  it 'fails login and does not redirect' do
    post :create, :email => 'quentin@example.com', :password => 'bad password'
    UserSession.find.should be_nil
    response.should be_success
  end

  it 'logs out' do
    UserSession.create FactoryGirl.create(:user)
    delete :destroy
    UserSession.find.should be_nil
    response.should be_redirect
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
