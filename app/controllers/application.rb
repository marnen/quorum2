# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.
require 'gettext/rails'

class ApplicationController < ActionController::Base
  include AuthenticatedSystem # for restful_authentication
  helper :all # include all helpers, all the time

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => 'efb0994fc16e17d478432d89deb46862'
  
  # Add gettext code for i18n, from http://manuals.rubyonrails.com/read/chapter/105
  init_gettext "quorum", "UTF-8", "text/html"
end
