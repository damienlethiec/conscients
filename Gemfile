# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

gem 'pg'
gem 'puma'
gem 'rails', '~> 5.2'

gem 'friendly_id-mobility'
# Content translation (like Globalize but much better) --> https://github.com/shioyama/mobility
gem 'mobility'
gem 'rails-i18n'

gem 'uglifier'
gem 'webpacker'

gem 'aws-sdk-s3', '~> 1.13', require: false
gem 'jbuilder'
gem 'mini_magick'
gem 'redis'

gem 'bootsnap', require: false
gem 'oj'
gem 'rollbar'

gem 'sidekiq'
gem 'sidekiq-failures'

# Analytics for rails --> https://github.com/ankane/ahoy
gem 'ahoy_matey'
gem 'devise'
gem 'devise-i18n'
gem 'devise_invitable'
gem 'gibbon'
gem 'omniauth-facebook', '~> 5.0'
gem 'postmark-rails'

gem 'activeadmin'
# Thème for activeadmin
gem 'arctic_admin'
# Search for active admin
gem 'ransack'

gem 'acts_as_list'
# Tree structure for models (categories in our case) --> https://github.com/stefankroes/ancestry
gem 'ancestry'
gem 'friendly_id'
# Static pages
gem 'high_voltage'
gem 'meta-tags'
# Clean respond with in controllers
gem 'responders'

gem 'aasm'
gem 'money-rails'
gem 'paypal-sdk-rest'
gem 'stripe'

gem 'kaminari'
gem 'pg_search'
gem 'wicked_pdf'
group :development, :test do
  gem 'wkhtmltopdf-binary', '~> 0.12'
end
group :production, :staging do
  gem 'wkhtmltopdf-heroku', '~> 2.12', '>= 2.12.4.0'
end

gem 'country_select'
gem 'font-awesome-rails'
gem 'sass-rails'

gem 'invisible_captcha'

# debugging
gem 'pgsync' # Sync Postgres data between databases (ex: from Production To Development)
gem 'pretender' # login as any user

group :development, :test do
  gem 'capybara'
  gem 'database_cleaner'
  gem 'factory_bot_rails'
  gem 'faker'
  gem 'pry-byebug'
  gem 'pry-rails'
  gem 'rspec-rails'
  gem 'webdrivers'
  gem 'selenium-webdriver'
  # gem 'factory_bot'
  gem 'factory_bot_rails'
  gem 'faker'
end

group :development do
  gem 'letter_opener'
  # Find back messages sent to letter_opener in a web interface
  gem 'letter_opener_web'

  gem 'listen'
  gem 'spring'
  gem 'spring-watcher-listen'

  gem 'annotate'
  gem 'awesome_print'
  # Possible to desactivate alerts if too annoying
  gem 'bullet'
  # Generate schéma of database automatically in erd.pdf
  gem 'rails-erd'

  gem 'brakeman', require: false
  gem 'overcommit'
  gem 'ruby-graphviz'
  gem 'rubocop-rails', require: false

  gem 'guard'
  gem 'guard-bundler', require: false
  gem 'guard-livereload', require: false
  gem 'rack-livereload'

  gem 'better_errors'
  gem 'binding_of_caller'
end
