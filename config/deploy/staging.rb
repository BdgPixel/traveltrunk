server '45.33.111.21', user: 'developer', roles: %w{app db web}

set :deploy_to, "/home/traveltrunk/rails_apps/#{fetch(:application)}_#{fetch(:stage)}"

set :rvm_ruby_version, "2.2.3@#{fetch(:application)}"

set :linked_files, fetch(:linked_files, []).push('config/database.yml', 'config/secrets.yml',
  'config/sidekiq.yml', '.env.staging', '.ruby-gemset')

set :linked_dirs, fetch(:linked_dirs, []).push('log', 'tmp/pids', 'tmp/cache', 'tmp/sockets',
  'vendor/bundle', 'public/system', 'public/uploads')

set :config_dirs, %W{config config/environments/#{fetch(:stage)} public/uploads}

set :config_files, %w{config/database.yml config/secrets.yml config/sidekiq.yml .env.staging .ruby-gemset}

set :sidekiq_env, fetch(:stage)