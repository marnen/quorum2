# Set up ExceptionNotifier.
# TODO: Should this go in production.rb instead?
Quorum2::Application.config.middleware.use ExceptionNotifier, {
  :email_prefix => "[#{SITE_TITLE}] ",
  :sender_address => %Q{"#{SITE_TITLE} errors" <quorum.pokingbrook@gmail.com>},
  :exception_recipients => APP_CONFIG['exception_recipients']
}
