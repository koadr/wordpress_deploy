set_default(:admin_password) { Capistrano::CLI.password_prompt "Root Password: " }

namespace :mysql do
  desc <<-EOF
      Create a database for this application. \
      You will need to enter both the admin_password \
      as well as the password for the database you are creating (mysql_password).
      EOF
  task :create_database, roles: :db, only: {primary: true} do
     on_rollback { drop_db }
     sql = <<-MYSQL
     CREATE DATABASE IF NOT EXISTS #{mysql_database};
     GRANT ALL ON #{mysql_database}.* TO '#{mysql_user}'@'%' IDENTIFIED BY '#{mysql_password}';
     GRANT RELOAD ON *.* TO '#{mysql_user}'@'%' IDENTIFIED BY '#{mysql_password}';
  MYSQL
    run "mysql --user=root --host=localhost --password=#{admin_password} --execute=\"#{sql}\""
  end
  after "deploy:setup", "mysql:create_database"


  desc <<-DESC
      Drop the MySQL database.
    DESC
    task :drop_db, :roles => :db do
      run "mysql --user=root --host=localhost --password=#{admin_password}  --execute=\"DROP DATABASE IF EXISTS #{mysql_database};\""
    end
end