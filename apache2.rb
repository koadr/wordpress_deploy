set_default(:email) { email }
set_default(:domain_alias) { "www.#{domain}" }

namespace :apache2 do
  desc "Setup apache2 configuration for application"
  task :setup, roles: :web do
    template "apache2.erb", "/tmp/apache2_conf"
    run "#{sudo} a2dissite default"
    run "#{sudo} mv /tmp/apache2_conf /etc/apache2/sites-available/#{application}"
    run "#{sudo} a2ensite #{application}"
    restart
  end
  after "deploy:setup", "apache2:setup"

  %w[start stop restart].each do |command|
    desc "#{command} apache2"
    task command, roles: :web do
      run "#{sudo} service apache2 #{command}"
    end
  end
end