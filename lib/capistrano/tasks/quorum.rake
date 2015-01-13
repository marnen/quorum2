namespace :deploy do
  desc 'Remove image sources.'
  task :remove_sources do
    on roles(:app) do
      within release_path do
        execute :rm, '-rf', 'app/assets/images/sources'
      end
    end
  end
end