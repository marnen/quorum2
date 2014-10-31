# coding: UTF-8

# Application globals go here.
#require 'gettext/rails'
require 'yaml'
APP_CONFIG = YAML.load_file("#{Rails.root}/config/config.yml")[Rails.env]

APP_VERSION = '0.5.15'

SITE_TITLE = "Quorum" # Name of site as it appears in <title> element

APP_HOME_PAGE = 'http://quorum2.sourceforge.net'

DOMAIN = APP_CONFIG['domain'] # Domain on which the site is hosted

EMAIL = APP_CONFIG['email'] # Address that application-generated e-mail will come from.

Date::DATE_FORMATS[:ical] = "%Y%m%d" # yyyymmdd, for iCal conversion

FONT_ROOT = "#{Rails.root}/fonts/dejavu-fonts-ttf-2.26/ttf"

GMAPS_API_KEY = YAML.load_file(File.join Rails.root, 'config', 'gmaps_api_key.yml')[Rails.env]
