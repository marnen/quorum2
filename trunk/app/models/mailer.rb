class Mailer < ActionMailer::Base
  # Sends an e-mail message to the #User with the supplied password.
  def reset(user, password)
    ActionMailer::Base.default_url_options[:host] = DOMAIN
    recipients user.email
    from EMAIL
    subject _('Quorum Password Reset')
    body :user => user, :password => password
  end
end
