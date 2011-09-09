# Application globals go here.
#require 'gettext/rails'
require 'yaml'
APP_CONFIG = YAML.load_file("#{Rails.root}/config/config.yml")[Rails.env]

SITE_TITLE = "Quorum" # Name of site as it appears in <title> element

DOMAIN = APP_CONFIG['domain'] # Domain on which the site is hosted

EMAIL = APP_CONFIG['email'] # Address that application-generated e-mail will come from.

GeoRuby::SimpleFeatures::DEFAULT_SRID = 4326

Time::DATE_FORMATS.merge :ical => "%Y%m%d" # yyyymmdd, for iCal conversion

FONT_ROOT = "#{RAILS_ROOT}/fonts/dejavu-fonts-ttf-2.26/ttf"
