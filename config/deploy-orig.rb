# config valid only for current version of Capistrano
lock '3.3.5'

set :application, 'quorum2'
set :repo_url, 'REPOSITORY_URL' # CONFIG: use a Git clone URL or SVN repo spec here.

# Default branch is :master
# ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }.call
# CONFIG: set as appropriate for your repository

# Default deploy_to directory is /var/www/my_app_name

# set :deploy_to, '/var/www/my_app_name'
set :deploy_to, 'PATH' # CONFIG: set the deploy path

# Default value for :scm is :git
# set :scm, :git
set :remote, 'origin' # CONFIG: set as appropriate for your repository

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
# set :log_level, :debug

# Default value for :pty is false
# set :pty, true

set :linked_files, fetch(:linked_files, []).push(
  'config/database.yml',
  'config/config.yml',
  'config/gmaps_api_key.yml',
  'config/initializers/secret_token.rb'
)

set :linked_dirs, fetch(:linked_dirs, []).push('bin', 'log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'vendor/bundle', 'public/system')

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
# set :keep_releases, 5

after 'deploy:updated', 'deploy:remove_sources'
after 'deploy:published', 'deploy:tag'

namespace :deploy do
  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      # Here we can do anything such as:
      # within release_path do
      #   execute :rake, 'cache:clear'
      # end
    end
  end
end
