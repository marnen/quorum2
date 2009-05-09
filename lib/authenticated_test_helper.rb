module AuthenticatedTestHelper
  # Sets the current user in the session. If stub_current_user is true, also stubs User.current_user appropriately.
  def login_as(user, stub_current_user = true)
    @request.session[:user_id] = user ? user.id : nil
    if stub_current_user
      User.stub!(:current_user).and_return(user)
    end
  end

  def authorize_as(user)
    @request.env["HTTP_AUTHORIZATION"] = user ? ActionController::HttpAuthentication::Basic.encode_credentials(user.login, 'test') : nil
  end
end
