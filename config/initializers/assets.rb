# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# Add additional assets to the asset load path
# Rails.application.config.assets.paths << Emoji.images_path

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in app/assets folder are already added.
Rails.application.config.assets.precompile += %w(
  payments.js
  variables.js
  groups.js
  profiles.js
  deals.js
  notifications.js
  search.js
  reservations.js
  sound_path.js
  flights.js
  profiles.css
  savings.css
  deals.css
  height.css
  custom.css
)
# Rails.application.config.assets.precompile += %w( groups.js galleria.classic.min.js variables.js profiles.js deals.js holder.js profiles.css deals.css)
