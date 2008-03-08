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

role :app, "ebon-askavi.homedns.org"
role :web, "ebon-askavi.homedns.org"
role :db,  "ebon-askavi.homedns.org", :primary => true