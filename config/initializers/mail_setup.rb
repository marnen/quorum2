# TODO: Consider using sendmail instead.
# Disable delivery errors, bad email addresses will be ignored
# config.action_mailer.raise_delivery_errors = false
smtp = APP_CONFIG['smtp']
ActionMailer::Base.smtp_settings = {
  :enable_starttls_auto => true,
  :address => smtp['address'],
  :port => smtp['port'],
  :user_name => smtp['user_name'],
  :password => smtp['password'],
  :authentication => (smtp['authentication'] || :plain)
}
