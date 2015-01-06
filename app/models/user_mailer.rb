# coding: UTF-8

class UserMailer < ActionMailer::Base
  # Sends an e-mail message to the #User with the supplied password.
  def reset(user)
    ActionMailer::Base.default_url_options[:host] = DOMAIN
    @user = user
    @password = user.password
    mail(
      to: user.email,
      from: EMAIL,
      subject: ["[#{SITE_TITLE}]", _('Password Reset')].join(' '),
      sent_on: Time.now
    )
  end
end
