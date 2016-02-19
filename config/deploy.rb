require 'capistrano/rvm'
require 'capistrano/bundler'
require 'bundler/deployment'
require 'whenever/capistrano'

SSHKit.config.command_map[:rake] = 'bundle exec rake'
SSHKit.config.command_map[:rails] = 'bundle exec rails'
# config valid only for current version of Capistrano
lock '3.4.0'

set :application, 'MaimitBlogs'
set :repo_url, 'https://github.com/maimitp9/sample_demo-sign-in-out.git'

# Default branch is :master
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

# Default deploy_to directory is /var/www/my_app_name
set :deploy_to, '/var/www/sample_demo-sign-in-out'
set :user, 'ubuntu'

# Default value for :scm is :git
#set :scm, :git

# Default value for :format is :pretty
# set :format, :pretty


# Default value for :log_level is :debug
# set :log_level, :debug

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
set :linked_files, %w(config/database.yml .env)

# Default value for linked_dirs is []
set :linked_dirs, fetch(:linked_dirs, []).push('log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'vendor/bundle', 'public/system')

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }
set :stages, %w(production)
#set :rails_env, 'production'
#set :deploy_via, :copy

# Default value for keep_releases is 5
set :keep_releases, 10

namespace :deploy do
desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      # Your restart mechanism here, for example:
      execute :touch, release_path.join('tmp/restart.txt')
    end
  end

  after :publishing, :restart

  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      # Here we can do anything such as:
      # within release_path do
      #   execute :rake, 'cache:clear'
      # end
    end
  end
  
   after :finishing, 'deploy:cleanup'

  desc 'Update the crontab file'
  task :update_crontab do
    on roles(:web, :app, :db) do
      execute 'crontab -r', raise_on_non_zero_exit: false
      within release_path do
        execute :bundle, :exec, 'whenever --update-crontab', raise_on_non_zero_exit: false
      end
    end
  end

end
