require "bundler/capistrano"

set :domain, "38.109.217.10"
set :application, "leadtraker"
set :deploy_to, "/home/web/#{application}"

# You can set :scm explicitly or Capistrano will make an intelligent guess based on known version control directory names
set :scm, :git # Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`
set :repository,  "git@github.com:priyankt/leadtraker_new.git"
set :branch, 'master'
set :git_shallow_clone, 1

set :rvm_type, :system

set :user, "web"
set :use_sudo, false

role :web, domain                          # Your HTTP server, Apache/etc
role :app, domain                          # This may be the same as your `Web` server
role :db,  domain, :primary => true # This is where Rails migrations will run
#role :db,  "your slave db-server here"

# if you want to clean up old releases on each deploy uncomment this:
after "deploy:restart", "deploy:cleanup"

namespace :deploy do
	task :start do ; end
	task :stop do ; end
	# Assumes you are using Passenger
	task :restart, :roles => :app, :except => { :no_release => true } do
		run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
	end

	task :finalize_update, :except => { :no_release => true } do
		run "chmod -R g+w #{latest_release}" if fetch(:group_writable, true)

		# mkdir -p is making sure that the directories are there for some SCM's that don't save empty folders
		run <<-CMD
		rm -rf #{latest_release}/log &&
		mkdir -p #{latest_release}/public &&
		mkdir -p #{latest_release}/tmp &&
		ln -s #{shared_path}/log #{latest_release}/log
		CMD
	end

	desc "Symlinks the database.rb"
	task :symlink_db, :roles => :app do
		run "rm -rf #{current_release}/config/database.rb"
		run "ln -nfs #{deploy_to}/shared/config/database.rb #{current_release}/config/database.rb"
	end

	# desc "Symlinks the upload directory"
	# task :symlink_upload, :roles => :app do
	# 	run "ln -nfs #{deploy_to}/shared/images/uploads #{current_release}/public/images/uploads"
	# end

	desc "Symlinks the lib/leadtraker_constants.rb"
	task :symlink_constants, :roles => :app do
		run "rm -rf #{current_release}/lib/leadtraker_constants.rb"
		run "ln -nfs #{deploy_to}/shared/config/leadtraker_constants.rb #{current_release}/lib/leadtraker_constants.rb"
	end
end

after 'deploy:update_code', 'deploy:symlink_db', 'deploy:symlink_constants'

namespace :gems do
  	task :install do
    	run "cd #{deploy_to}/current && RAILS_ENV=production bundle install"
  	end
end

namespace :database do
  	task :upgrade do
    	run "cd #{deploy_to}/current && bundle exec padrino rake dm:auto:upgrade -e production"
  	end
end

namespace :database do
  	task :seed do
    	run "cd #{deploy_to}/current && bundle exec padrino rake db:seed -e production"
  	end
end

desc "Hot-reload God configuration for the Resque worker"
deploy.task :reload_god_config do
	run "cd #{deploy_to}/current && bundle exec god stop leadtraker-resque"
	run "cd #{deploy_to}/current && bundle exec god load #{File.join deploy_to, 'current', 'config', 'resque.god'}"
	run "cd #{deploy_to}/current && bundle exec god start leadtraker-resque"

	run "cd #{deploy_to}/current && bundle exec god stop leadtraker-resque-scheduler"
	run "cd #{deploy_to}/current && bundle exec god load #{File.join deploy_to, 'current', 'config', 'resque_scheduler.god'}"
	run "cd #{deploy_to}/current && bundle exec god start leadtraker-resque-scheduler"
end

after :deploy, "gems:install", "database:upgrade", "database:seed", "deploy:reload_god_config"