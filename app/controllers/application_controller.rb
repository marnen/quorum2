# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.
class ApplicationController < ActionController::Base
  filter_parameter_logging :password
  
  before_filter :set_gettext_locale
  
  ActionView::Helpers::TextHelper::BlueCloth = RDiscount
  
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
  
  # Return true if the current user is admin, otherwise give an error and redirect. Meant as a before_filter.
  def check_admin
    if admin?
      return true
    else
      flash[:error] = _('You are not authorized to perform that action.')
      begin
        redirect_to :back
      rescue
        redirect_to root_url
      end
    end
  end

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => 'efb0994fc16e17d478432d89deb46862'
  
protected
  def admin
    @admin ||= Role.find_by_name('admin')
    @admin
  end

  def set_current_user
    User.current_user = self.current_user
  end
  
  def set_gettext_locale
    FastGettext.text_domain = SITE_TITLE
    FastGettext.available_locales = ['en'] #all you want to allow
    begin
      super
    rescue NoMethodError
      # don't worry about it
    end
  end
end
