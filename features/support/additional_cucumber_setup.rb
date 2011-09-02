# Require spec_helper so we can use blueprints.
require "#{RAILS_ROOT}/spec/blueprints"

# Set Gettext stuff so we can load Web pages.
FastGettext.text_domain ||= SITE_TITLE
FastGettext.available_locales ||= ['en']