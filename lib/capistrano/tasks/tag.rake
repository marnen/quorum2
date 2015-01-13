# Adapted from https://gist.github.com/rsutphin/9010923
namespace :deploy do
  after :finishing, :tag_and_push_tag do
    on roles(:app) do
      within release_path do
        set(:current_revision, capture(:cat, 'REVISION'))

        # release path may be resolved already or not
        resolved_release_path = capture(:pwd, "-P")
        set(:release_name, resolved_release_path.split('/').last)
      end
    end

    run_locally do
      remote = fetch :remote

      user = capture(:git, "config --get user.name").chomp
      email = capture(:git, "config --get user.email").chomp
      tag_msg = "Deployed by #{user} <#{email}> to #{fetch :stage} as #{fetch :release_name}"

      tag_name = "#{remote}_#{fetch :stage }_#{fetch :release_name}"
      execute :git, %(tag #{tag_name} #{fetch :current_revision} -m "#{tag_msg}")
      execute :git, "push --tags #{remote}"
    end
  end
end