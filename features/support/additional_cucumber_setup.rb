# coding: UTF-8

require 'ruby-debug'

# Set Gettext stuff so we can load Web pages.
FastGettext.text_domain ||= SITE_TITLE
FastGettext.available_locales ||= ['en']