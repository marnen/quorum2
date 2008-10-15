require File.dirname(__FILE__) + '/../spec_helper'

describe UsersController do
  fixtures :users

  it 'allows signup' do
    @user = User.new
    User.should_receive(:new).and_return(@user)
    @user.should_receive(:save).at_least(:once).and_return(true)
    create_user
  end

  
# Uncomment this spec when we set up e-mail activation.
=begin  
  it 'signs up user with activation code' do
    create_user
    assigns(:user).activation_code.should_not be_nil
  end
=end

  it 'requires password on signup' do
    lambda do
      create_user(:password => nil)
      assigns[:user].errors.on(:password).should_not be_nil
      response.should be_success
    end.should_not change(User, :count)
  end
  
  it 'requires password confirmation on signup' do
    lambda do
      create_user(:password_confirmation => nil)
      assigns[:user].errors.on(:password_confirmation).should_not be_nil
      response.should be_success
    end.should_not change(User, :count)
  end

  it 'requires email on signup' do
    lambda do
      create_user(:email => nil)
      assigns[:user].errors.on(:email).should_not be_nil
      response.should be_success
    end.should_not change(User, :count)
  end
  
  
  it 'activates user' do
    User.authenticate('aaron@example.com', 'test').should be_nil
    get :activate, :activation_code => users(:aaron).activation_code
    response.should redirect_to('/login')
    flash[:notice].should_not be_nil
    User.authenticate('aaron@example.com', 'test').should == users(:aaron)
  end
  
  it 'does not activate user without key' do
    get :activate
    flash[:notice].should be_nil
  end
  
  it 'does not activate user with blank key' do
    get :activate, :activation_code => ''
    flash[:notice].should be_nil
  end
  
  def create_user(options = {})
    post :create, :user => { :login => 'quire', :email => 'quire@example.com',
    :password => 'quire', :password_confirmation => 'quire', :permissions => [mock_model(Permission)] }.merge(options)
  end
end

describe UsersController, "edit" do
  fixtures :users
  
  before(:each) do
    login_as :marnen
    get :edit
  end
  
  it "should reuse the 'new' form" do
    response.should render_template :new
  end
  
  it "should get the current user" do
    assigns[:user].should == User.current_user
  end
  
  it "should not require password validation if both password fields are nil" do
    marnen = users(:marnen)
    my_attr = marnen.attributes
    my_attr[:password] = nil
    my_attr[:password_confirmation] = nil
    User.stub!(:current_user).and_return(users(:marnen))
    post :edit, :user => my_attr
    marnen.errors.should be_empty
  end
  
  it "should validate password if at least one password field is supplied" do
    User.stub!(:current_user).and_return(users(:marnen))
    marnen = users(:marnen)
 
    my_attr = marnen.attributes
    my_attr[:password] = 'a'
    my_attr[:password_confirmation] = nil
    my_attr.should_not be_nil
    post :edit, :user => my_attr
    marnen.errors.should_not be_empty

    get :edit
    marnen = users(:marnen)
    my_attr = marnen.attributes
    my_attr[:password] = nil
    my_attr[:password_confirmation] = 'a'
    my_attr.should_not be_nil
    post :edit, :user => my_attr
    marnen.errors.should_not be_empty
  end
  
  it "should set coords to nil" do
    marnen = users(:marnen)
    User.stub!(:current_user).and_return(marnen)
    post :edit, :user => marnen.attributes
    marnen.should_receive(:coords_from_string)
    marnen.coords
    # pending "Not sure if this spec is working properly."
  end
end

describe UsersController, '(list)' do
  before(:each) do
    non_admin_role = mock_model(Role, :name => 'user')
    @non_admin_user = mock_model(User, :role => non_admin_role)

    admin_role = mock_model(Role, :name => 'admin')
    @admin_user = mock_model(User, :role => admin_role)

    User.stub!(:current_user).and_return(@admin_user)
  end
  
  it "should be a valid action" do
    get :list
    response.should be_success
  end
  
  it "should set the page title" do
    get :list
    assigns[:page_title].should_not be_nil
  end
  
  it "should only be available for admin users" do
    get :list
    flash[:error].should be_nil
  end
  
  it "should redirect to / with an error for non-admin users" do
    User.stub!(:current_user).and_return(@non_admin_user)
    get :list
    flash[:error].should_not be_nil
    response.should redirect_to(root_url)
  end
  
  it "should use the list template" do
    get :list
    response.should render_template :list
  end
  
  it "should get a list of users" do
    users = [mock_model(User), mock_model(User), mock_model(User)]
    User.should_receive(:find).with(:all, :order => 'lastname, firstname').and_return(users)
    get :list
    assigns[:users].should_not be_nil
    assigns[:users].should be_a_kind_of(Array)
    assigns[:users].should == users
  end
end