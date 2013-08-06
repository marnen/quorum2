# coding: UTF-8

require 'spec_helper'

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
    UserMailer.should_receive(:deliver_reset).with(@user).at_least(:once).and_return(true)
    post :reset, :email => @user.email
    flash[:error].should be_nil
    flash[:notice].should_not be_nil
  end
end