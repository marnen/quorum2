class UserMailer < ActionMailer::Base
  def signup_notification(user)
    setup_email(user)
    @subject    += _('Please activate your new account')
  
    @body[:url]  = "http://#{DOMAIN}/activate/#{user.activation_code}"
  
  end
  
  def activation(user)
    setup_email(user)
    @subject    += _('Your account has been activated!')
    @body[:url]  = "http://#{DOMAIN}/"
  end
  
  # Sends an e-mail message to the #User with the supplied password.
  def reset(user, password)
    setup_email(user)
    @subject += _('Password Reset')
    @body[:password] = password
  end

  protected
    def setup_email(user)
      ActionMailer::Base.default_url_options[:host] = DOMAIN
      @recipients  = "#{user.email}"
      @from        = EMAIL
      @subject     = "[#{SITE_TITLE}] "
      @sent_on     = Time.now
      @body[:user] = user
    end
end
