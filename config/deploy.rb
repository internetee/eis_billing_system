# config valid for current version and patch releases of Capistrano
lock "~> 3.16.0"

set :application, "eis_billing_system"
set :repo_url, "git@github.com:internetee/eis_billing_system.git"
# set :repo_url, "https://github.com/internetee/eis_billing_system.git"
set :branch, ENV['BRANCH'] || :master

# Default branch is :master
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

# Default deploy_to directory is /var/www/my_app_name
# set :deploy_to, "/var/www/my_app_name"
set :passenger_restart_with_touch, true
set :deploy_to, "/home/deploy/#{fetch :application}"
set :rails_env, "staging"
# Default value for :format is :airbrussh.
# set :format, :airbrussh

# You can configure the Airbrussh format using :format_options.
# These are the defaults.
# set :format_options, command_output: true, log_file: "log/capistrano.log", color: :auto, truncate: :auto

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
# append :linked_files, "config/database.yml"

# Default value for linked_dirs is []
# append :linked_dirs, "log", "tmp/pids", "tmp/cache", "tmp/sockets", "public/system"
# append :linked_dirs, 'log', 'storage', 'tmp/cache', '.bundle'
# set :assets_dependencies, %w(Gemfile.lock config/routes.rb)
append :linked_dirs, 'log', 'storage', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'vendor/bundle', '.bundle', 'public/system', 'public/uploads'
set :assets_dependencies, %w(app/assets lib/assets vendor/assets Gemfile.lock config/routes.rb)
set :linked_files, %w{config/application.yml}
# set :linked_files, %w{config/application.yml}
# app/assets lib/assets vendor/assets
# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }
set :keep_releases, 5

# Default value for local_user is ENV['USER']
# set :local_user, -> { `git config user.name`.chomp }

# Default value for keep_releases is 5
# set :keep_releases, 5

# Uncomment the following to require manually verifying the host key before first deploy.
# set :ssh_options, verify_host_key: :secure
namespace :deploy do
  namespace :assets do
    task :precompile do
      puts "No precompile"
    end
  end
  
  task :symlink_config do
    on roles(:app) do
      execute "ln -nfs #{shared_path}/config/application.yml #{release_path}/config/application.yml"
    end
  end

  task :symlink_lhv_connect do
    on roles(:app) do
      execute "ln -nfs #{shared_path}/config/EESTIINTERNETISA.p12 #{release_path}/EESTIINTERNETISA.p12"
    end
  end

  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      execute :touch, release_path.join('tmp/restart.txt')
    end
  end

  after :publishing, 'deploy:restart'
  after :finishing, 'deploy:cleanup'
end
