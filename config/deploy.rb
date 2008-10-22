set :application, "quorum2"
set :repository,  "http://svn.ebon-askavi.homedns.org:8080/marnen/quorum2/trunk/"

# If you aren't deploying to /u/apps/#{application} on the target
# servers (which is the default), you can specify the actual location
# via the :deploy_to variable:
set :deploy_to, "/var/vhosts/#{application}"
set :user, "capistrano"

# If you aren't using Subversion to manage your source code, specify
# your SCM below:
# set :scm, :subversion
set :scm_user, "marnen"
=begin
set :scm_password, Proc.new { Capistrano::CLI.password_prompt("SVN 
password for #{scm_user}, please: ") } 
set :repository, Proc.new { "--username #{scm_user} --password 
#{scm_password} --no-auth-cache #{repository}" }
=end

role :app, "ebon-askavi.homedns.org"
role :web, "ebon-askavi.homedns.org"
role :db,  "ebon-askavi.homedns.org", :primary => true

# set process runner
set :runner, "capistrano" # might want to change this
set :use_sudo, false

# get GemInstaller working

namespace :deploy do
  task :after_update_code do
    ############# Begin GemInstaller config - see http://geminstaller.rubyforge.org
    require "rubygems" 
    require "geminstaller" 
    
    # Path(s) to your GemInstaller config file(s)
    config_paths = "#{File.expand_path(release_path)}/config/geminstaller.yml" 
    
    # Arguments which will be passed to GemInstaller (you can add any extra ones)
    args = "--config #{config_paths}" 
    
    # The 'exceptions' flag determines whether errors encountered while running GemInstaller
    # should raise exceptions (and abort Rails), or just return a nonzero return code
    args += " --exceptions" 
    
    # This will use sudo by default on all non-windows platforms, but requires an entry in your
    # sudoers file to avoid having to type a password.  It can be omitted if you don't want to use sudo.
    # See http://geminstaller.rubyforge.org/documentation/documentation.html#dealing_with_sudo
    args += " --sudo" unless RUBY_PLATFORM =~ /mswin/ 
    
    # And show some output...
    args += " --geminstaller-output=all --rubygems-output=all"
    
    # The 'install' method will auto-install gems as specified by the args and config
    # GemInstaller.run(args)
    run "/usr/bin/geminstaller #{args}"
    
    # The 'autogem' method will automatically add all gems in the GemInstaller config to your load path, using the 'gem'
    # or 'require_gem' command.  Note that only the *first* version of any given gem will be loaded.
    # GemInstaller.autogem(args)
    ############# End GemInstaller config
  end
end