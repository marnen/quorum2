require File.dirname(__FILE__) + '/../spec_helper'

describe UsersController do
  it 'allows signup' do
    @user = User.make
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
    email = 'aaron@example.com'
    password = 'test'
    aaron = User.make(:inactive, :email => email, :password => password)
    User.authenticate(email, password).should be_nil
    get :activate, :activation_code => aaron.activation_code
    response.should redirect_to('/login')
    flash[:notice].should_not be_nil
    User.authenticate(email, password).should == aaron
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
 before(:each) do
    @user = User.make
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
    test_user = User.make
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
      @user[:password] = 'a'
      @user[:password_confirmation] = nil
      my_attr.should_not be_nil
      post :edit, @user
      @user.errors.should_not be_empty
  
      @user = User.make
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
    controller.stub!(:login_required).and_return(true)
  end
  
  it "should be a valid action" do
    User.stub!(:current_user).and_return(mock_model(User, :null_object => true))
    get :regenerate_key
    response.should redirect_to(:back)
  end
  
  it "should change the current user's feed_key" do
    @current_user = mock_model(User, :feed_key => 'abc123')
    @current_user.should_receive(:feed_key=).with(nil).ordered
    @current_user.should_receive(:save!)
    User.stub!(:current_user).and_return(@current_user)
    get :regenerate_key
  end
  
  it 'should set flash[:notice] on success' do
    User.stub!(:current_user).and_return(mock_model(User, :null_object => true))
    get :regenerate_key
    flash[:notice].should_not be_nil
  end

  it 'should set flash[:error] on failure' do
    @current_user = mock_model(User, :null_object => true)
    @current_user.should_receive(:save!).and_raise
    User.stub!(:current_user).and_return(@current_user)
    get :regenerate_key
    flash[:error].should_not be_nil
  end
end

describe UsersController, '(reset)' do
  integrate_views
  
  before(:each) do
    get :reset
  end
  
  it "should be a valid action" do
    response.should be_success
  end
  
  it "should display a form asking for e-mail address, with a submit button" do
    response.should have_tag('input[type=text]')
    response.should have_tag('input[type=submit]')
  end
  
  it "should set the page title" do
    assigns[:page_title].should_not be_blank
  end
end

describe UsersController, '(reset/POST)' do
  integrate_views
  
  it "should give an error message if e-mail isn't valid" do
    User.should_receive(:find_by_email).and_return(nil)
    post :reset, :email => 'someone@example.com'
    flash[:error].should_not be_nil
  end
  
  it "should reset password if e-mail is valid" do
    @user = User.make
    @user.should_receive(:reset_password!).and_return(true)
    User.should_receive(:find_by_email).and_return(@user)
    UserMailer.should_receive(:deliver_reset).with(@user).at_least(:once).and_return(true)
    post :reset, :email => @user.email
    flash[:error].should be_nil
    flash[:notice].should_not be_nil
  end
end