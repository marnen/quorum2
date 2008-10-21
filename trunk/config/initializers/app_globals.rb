# Application globals go here.
require 'gettext/rails'

SITE_TITLE = "Quorum" # Name of site as it appears in <title> element

DOMAIN = "quorum2.ebon-askavi.homedns.org:8080" # Domain on which the site is hosted

EMAIL = "quorum@marnen.org" # Address that application-generated e-mail will come from.

GeoRuby::SimpleFeatures::DEFAULT_SRID = 4326

module ActiveSupport::CoreExtensions::Date::Conversions
  DATE_FORMATS[:ical] = "%Y%m%d" # yyyymmdd, for iCal conversion
end