# coding: UTF-8

begin
  require 'ruby-debug'
rescue LoadError
  warn 'Failed to load ruby-debug; continuing without it...'
end

# Set Gettext stuff so we can load Web pages.
FastGettext.text_domain ||= SITE_TITLE
FastGettext.available_locales ||= ['en']