namespace :gettext do
  desc "Create mo-files for L10n" 
  task :makemo do
    require 'gettext/utils'
    GetText.create_mofiles(true, "po", "locale")
  end
  
  desc "Update pot/po files to match new version." 
  task :updatepo do
    require 'gettext/utils'
    require 'haml_parser'
    MY_APP_TEXT_DOMAIN = "quorum" 
    MY_APP_VERSION     = "quorum 2 beta" 
    GetText.update_pofiles(MY_APP_TEXT_DOMAIN, Dir.glob("{app,lib}/**/*.{rb,rhtml,erb,haml}"), MY_APP_VERSION)
  end
end