namespace :gettext do
  desc "Create mo-files for L10n" 
  task :makemo do
    require 'gettext/utils'
    GetText.create_mofiles(true, "po", "locale")
  end
  
  desc "Update pot/po files to match new version." 
  task :updatepo do
    require 'gettext/utils'
    MY_APP_TEXT_DOMAIN = "quorum" 
    MY_APP_VERSION     = "quorum 2.0.0" 
    GetText.update_pofiles(MY_APP_TEXT_DOMAIN, Dir.glob("{app,lib}/**/*.{rb,rhtml,erb}"), MY_APP_VERSION)
  end
end