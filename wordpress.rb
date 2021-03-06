set :app_symlinks, ["uploads"]
before  'deploy:update_code', 'wordpress:symlinks:setup'
after  'deploy:symlink', 'wordpress:symlinks:uploads'

namespace :wordpress do
  desc <<-EOF
    Uploads and links the unversioned uploads directory. \
    Neglected to put the media library files under source. \
    Also uploads the config file \
    which was not under source control for obvious reasons.
  EOF
  namespace :symlinks do
    desc "Setup uploads directory in #{shared_path} directory"
    task :setup, :roles => [:web] do
      if app_symlinks
        app_symlinks.each do |link|
          run "mkdir -p #{shared_path}/#{link}"
          run "#{sudo} chmod 777 #{shared_path}/#{link}"
        end
      end
    end

    desc "Moves upload directory in #{shared_path} to wp-content/uploads folder in #{release_path}."
    task :uploads, :roles => :app do
      upload("application/wp-content/uploads/", "#{shared_path}/", :via=> :scp, :recursive => true)
      run "#{sudo} chmod 777 -R #{shared_path}/uploads/"
      run "ln -nfs #{shared_path}/uploads/ #{current_path}/application/wp-content/uploads"
    end
  end
end