require 'bundler/capistrano'

set :application, "quorum2"
set :repository,  "REPOSITORY_URL" # CONFIG: use a Git clone URL or SVN repo spec here.

# If you aren't deploying to /u/apps/#{application} on the target
# servers (which is the default), you can specify the actual location
# via the :deploy_to variable:
set :deploy_to, "PATH" # CONFIG: set the deploy path
set :user, "capistrano"

# If you aren't using Subversion to manage your source code, specify
# your SCM below:
# set :scm, :subversion
# set :scm_user, "capistrano"
set :scm, :git
set :branch, :master
set :deploy_via, :remote_cache
set :git_enable_submodules, 1

=begin
set :scm_password, Proc.new { Capistrano::CLI.password_prompt("SVN 
password for #{scm_user}, please: ") } 
set :repository, Proc.new { "--username #{scm_user} --password 
#{scm_password} --no-auth-cache #{repository}" }
=end

# CONFIG: normally this will be the name of your application server.
role :app, "HOST"
role :web, "HOST"
role :db,  "HOST", :primary => true

# set process runner
set :runner, "capistrano" # might want to change this
set :use_sudo, false

# get GemInstaller working

namespace :deploy do
  
  # CONFIG: Comment out task :restart block unless you're using Phusion Passenger -- it won't work with other servers
  desc 'Restart the application server.'
  task :restart, :roles => :app do
    run "if test ! -d #{current_path}/tmp; then mkdir #{current_path}/tmp; fi"
    run "/usr/bin/touch #{current_path}/tmp/restart.txt"
  end
  
  task :after_update_code do
    # Remove some unversioned YAML config files and link to shared directory.
    rpath = File.expand_path(release_path)
    ['database.yml', 'config.yml', 'gmaps_api_key.yml'].each do |file|
      run "rm -f #{rpath}/config/#{file}"
      run "ln -s #{deploy_to}/shared/config/#{file} #{rpath}/config/#{file}"
    end

    # Remove image source files.
    run "rm -rf #{rpath}/public/images/sources"
    
    #run "chown www-data #{current_path}/config/environment.rb"

  end
end
