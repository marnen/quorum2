module AuthenticatedTestHelper
  # Sets the current user in the session.
  def login_as(user)
    @request.session[:user_id] = user ? user.id : nil
  end

  def authorize_as(user)
    @request.env["HTTP_AUTHORIZATION"] = user ? ActionController::HttpAuthentication::Basic.encode_credentials(user.login, 'test') : nil
  end
end
