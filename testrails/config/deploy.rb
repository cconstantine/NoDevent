require 'bundler/capistrano'

#Basic config
set :application, "NoDevent"
set :repository, "git@github.com:cconstantine/NoDevent.git"
set :scm, "git"
set :user, "www-data"
set :git_shallow_clone, 1
set :deploy_to, "/var/www/nodevent"
default_run_options[:pty] = true


#Bundler
set :bundle_dir,          fetch(:shared_path)+"/bundle"
set :bundle_flags,       "--deployment --quiet"

#Servers
role :app, "nodevent.com"
role :db, "nodevent.com", :primary => true


before "deploy:symlink", "deploy:migrate"
    
set :unicorn_pid, "#{shared_path}/pids/unicorn.pid"
require 'capistrano-unicorn'

