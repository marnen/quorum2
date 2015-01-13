namespace :deploy do
  desc 'Remove image sources.'
  task :remove_sources do
    on roles(:app) do
      within release_path do
        run "rm -rf app/assets/images/sources"
      end
    end
  end

  # From http://stackoverflow.com/questions/5735656/tagging-release-before-deploying-with-capistrano
  desc 'Tags deployed release with a unique Git tag.'
  task :tag do
    user = `git config --get user.name`.chomp
    email = `git config --get user.email`.chomp
    tag_name = "#{remote}_#{release_timestamp}"
    puts `git tag #{tag_name} #{latest_revision} -m "Deployed by #{user} <#{email}>"`
    puts `git push #{remote} #{tag_name}`
  end
end