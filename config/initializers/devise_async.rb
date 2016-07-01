Devise::Async.setup do |config|
  config.enabled = false
  config.backend = :sidekiq
end