# coding: UTF-8

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
set :remote, 'origin'

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

after 'deploy:update_code', 'deploy:remove_unnecessary_files', 'deploy:tag'

namespace :deploy do
  
  # CONFIG: Comment out task :restart block unless you're using Phusion Passenger -- it won't work with other servers
  desc 'Restart the application server.'
  task :restart, :roles => :app do
    run "if test ! -d #{current_path}/tmp; then mkdir #{current_path}/tmp; fi"
    run "/usr/bin/touch #{current_path}/tmp/restart.txt"
  end
  
  desc 'Remove shared files and image sources.'
  task :remove_unnecessary_files, :roles => :app do
    # Remove some unversioned YAML config files and link to shared directory.
    rpath = File.expand_path(release_path)
    ['database.yml', 'config.yml', 'gmaps_api_key.yml', 'initializers/secret_token.rb'].each do |file|
      run "rm -f #{rpath}/config/#{file}"
      run "ln -s #{deploy_to}/shared/config/#{file} #{rpath}/config/#{file}"
    end

    # Remove image source files.
    run "rm -rf #{rpath}/public/images/sources"
    
    #run "chown www-data #{current_path}/config/environment.rb"

  end
  
  # From http://stackoverflow.com/questions/5735656/tagging-release-before-deploying-with-capistrano
  desc 'Tags deployed release with a unique Git tag.'
  task :tag do
    user = `git config --get user.name`.chomp
    email = `git config --get user.email`.chomp
    tag_name = "#{remote}_#{release_name}"
    puts `git tag #{tag_name} #{latest_revision} -m "Deployed by #{user} <#{email}>"`
    puts `git push #{remote} #{tag_name}`
  end
end
