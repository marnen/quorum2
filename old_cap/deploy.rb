# coding: UTF-8

require 'bundler/capistrano'
require 'rvm1/capistrano3'

if ENV['DEPLOY'] == 'demo'
  demo = true
else
  demo = false
end

set :application, "quorum2"
set :repository,  "git@pokingbrook.dtdns.net:quorum2.git" # CONFIG: use a Git clone URL or SVN repo spec here.
if !demo
  ssh_options[:keys] = [File.join(ENV["HOME"], ".ssh", "id_rsa-capistrano-pokingbrook")]
end

# If you aren't deploying to /u/apps/#{application} on the target
# servers (which is the default), you can specify the actual location
# via the :deploy_to variable:
set :deploy_to, demo ? "/home/quorum2/#{application}" : "/var/vhosts/#{application}" # CONFIG: set the deploy path
set :user, 'quorum2'


# If you aren't using Subversion to manage your source code, specify
# your SCM below:
# set :scm, :subversion
# set :scm_user, "capistrano"
# ssh_options[:keys] = %w{/Users/marnen/.ssh/id_dsa /Users/marnen/.ssh/id_rsa}
set :scm, :git
set :branch, 'deploy'
set :deploy_via, demo ? :copy : :remote_cache
set :remote, 'rackspace'

# Path specification because I don't have root access on demo host
if demo
  # set :scm_command, '/home/quorum2/bin/git'
  set :local_scm_command, 'git'
  set :scm_verbose, true
end

=begin
set :scm_password, Proc.new { Capistrano::CLI.password_prompt("SVN
password for #{scm_user}, please: ") }
set :repository, Proc.new { "--username #{scm_user} --password
#{scm_password} --no-auth-cache #{repository}" }
=end

# CONFIG: normally this will be the name of your application server.
server = demo ? 'quorum2.ambitiouslemon.com' : 'pokingbrook.dtdns.net'
role :app, server
role :web, server
role :db,  server, :primary => true

# set process runner
set :runner, "capistrano" # might want to change this
set :use_sudo, false

set :migrate_target, :current

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
    ['database.yml', 'config.yml', 'gmaps_api_key.yml', 'initializers/secret_token.rb', 'setup_load_paths.rb'].each do |file|
      run "rm -f #{rpath}/config/#{file}"
      run "ln -s #{deploy_to}/shared/config/#{file} #{rpath}/config/#{file}"
    end

    # Remove image source files.
    run "rm -rf #{rpath}/assets/images/sources"

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
