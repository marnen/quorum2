require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe AdminController do
  it "should not let non-admin users in" do
    User.stub!(:current_user).and_return(mock_model(User, :roles => []))
    get :admin, :action => :index
    response.should redirect_to :back
  end
end
