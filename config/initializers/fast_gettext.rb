require 'gettext_i18n_rails/string_interpolate_fix' # TODO: Do we actually need this?

FastGettext.add_text_domain 'app', :path => File.join(Rails.root, 'locale'), :type => :po
FastGettext.default_available_locales = ['en'] #all you want to allow
FastGettext.default_text_domain = 'app'
