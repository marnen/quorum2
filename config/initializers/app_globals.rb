# Application globals go here.
require 'gettext/rails'

SITE_TITLE = "Quorum" # Name of site as it appears in <title> element

# CONFIG: replace DOMAIN and EMAIL with reasonable values.
DOMAIN = "DOMAIN" # Domain on which the site is hosted

EMAIL = "EMAIL" # Address that application-generated e-mail will come from.

GeoRuby::SimpleFeatures::DEFAULT_SRID = 4326

module ActiveSupport::CoreExtensions::Date::Conversions
  DATE_FORMATS[:ical] = "%Y%m%d" # yyyymmdd, for iCal conversion
end