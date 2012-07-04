# coding: UTF-8

# Application globals go here.
#require 'gettext/rails'
require 'yaml'
APP_CONFIG = YAML.load_file("#{Rails.root}/config/config.yml")[Rails.env]

APP_VERSION = '0.5.8'

SITE_TITLE = "Quorum" # Name of site as it appears in <title> element

APP_HOME_PAGE = 'http://quorum2.sourceforge.net'

DOMAIN = APP_CONFIG['domain'] # Domain on which the site is hosted

EMAIL = APP_CONFIG['email'] # Address that application-generated e-mail will come from.

GeoRuby::SimpleFeatures::DEFAULT_SRID = 4326 # TODO: should this become an rgeo reference?

Date::DATE_FORMATS[:ical] = "%Y%m%d" # yyyymmdd, for iCal conversion

FONT_ROOT = "#{Rails.root}/fonts/dejavu-fonts-ttf-2.26/ttf"
