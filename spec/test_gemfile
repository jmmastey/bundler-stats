source 'https://rubygems.org'
# ruby '2.1.0', engine: 'rbx', engine_version: '2.2.10'

gem 'rails', '4.2.0'
gem 'sass-rails', '~> 4.0.2'
gem 'uglifier', '>= 1.3.0'
gem 'coffee-rails', '~> 4.0.0'
gem 'jquery-rails'
gem 'turbolinks'
gem 'jquery-turbolinks'
gem 'jbuilder'
gem 'bootstrap-sass'
gem 'devise'
gem 'haml-rails'
gem 'pg'
gem 'rolify'
gem 'state_machine'
gem 'gravatar_image_tag'
gem 'puma', ">= 2.0"
gem 'omniauth-github'
gem 'activerecord-session_store'
gem 'will_paginate'
gem 'will_paginate-bootstrap'
# gem 'rack-mini-profiler'
gem 'dotenv'

gem 'mail', '~> 2.5.4' # workaround for http://stackoverflow.com/questions/25984067/argumenterror-method-sort-given-0-expected-1-when-sending-a-confirmation

group :development do
  gem 'foreman'
  gem 'quiet_assets'
  gem 'rubocop'
  gem 'rubocop-rspec'
end

group :development, :test do
  gem 'factory_girl_rails'
  gem 'pry-rails', require: false
  gem 'rspec-rails'
  gem 'poltergeist'

  # other test deps
  gem 'rake'
  gem 'capybara'
  gem 'cucumber-rails', require: false
  gem 'database_cleaner', '1.0.1'
  gem 'email_spec'
  gem 'spring'
  gem 'spring-commands-rspec' # since we're using rspec

  # guard stuff
  gem 'guard-bundler'
  gem 'guard-rails'
  gem 'guard-rspec'
  gem 'guard-cucumber'
  gem 'rb-fchange', :require=>false
  gem 'rb-fsevent', :require=>false
  gem 'rb-inotify', :require=>false
end

group :production do
  gem 'rails_12factor'
  gem 'newrelic_rpm'
end
