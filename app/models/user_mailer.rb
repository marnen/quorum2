# coding: UTF-8

class UserMailer < ActionMailer::Base
  # Sends an e-mail message to the #User with the supplied password.
  def reset(user)
    setup_email(user)
    @subject += _('Password Reset')
    @body[:password] = user.password
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
