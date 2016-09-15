lock '3.5.0'

set :application, 'travel_trunk'

set :repo_url, 'git@github.com:41studio/TravelTrunk.git'

set :branch, (ENV['BRANCH'] || :production)

set :bundle_path, nil

set :bundle_binstubs, nil

set :bundle_flags, '--system'

set :pty, true

set :keep_releases, 5

set :sidekiq_monit_use_sudo, true

set :sidekiq_config, 'config/sidekiq.yml'

set :sidekiq_processes, 1

set :whenever_identifier, ->{ "#{fetch(:application)}_#{fetch(:stage)}" }