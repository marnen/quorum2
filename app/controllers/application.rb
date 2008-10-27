# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.
require 'gettext/rails'

class ApplicationController < ActionController::Base
  include AuthenticatedSystem # for restful_authentication
  
  # see http://www.ruby-forum.com/topic/51782
  before_filter :login_from_cookie
  before_filter :set_current_user 
  
  helper :all # include all helpers, all the time

  # Check to see if the current user is an admin of at least one calendar.
  def admin?
    u = User.current_user
    if u.nil? or u == false
      return nil
    else
      return u.admin?
    end
  end
  
  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => 'efb0994fc16e17d478432d89deb46862'
  
  # Add gettext code for i18n, from http://manuals.rubyonrails.com/read/chapter/105
  init_gettext "quorum", "UTF-8", "text/html"
  
 protected
  def admin
    @admin ||= Role.find_by_name('admin')
    @admin
  end

  def set_current_user
    User.current_user = self.current_user
  end
end
