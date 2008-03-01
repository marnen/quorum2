# Application globals go here.

SITE_TITLE = "Quorum" # Name of site as it appears in <title> element

DOMAIN = "quorum2.ebon-askavi.homedns.org" # Domain on which the site is hosted

module ActiveSupport::CoreExtensions::Date::Conversions
  DATE_FORMATS[:ical] = "%Y%m%d" # yyyymmdd, for iCal conversion
end