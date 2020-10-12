# frozen_string_literal: true

source 'https://rubygems.org'

gem 'json'
gem 'pg' # Postgresql
gem 'sequel' # Simple SQL database access toolkit

group :development do
  gem 'dotenv-rails' # Allow loading .env into ENV in development
  gem 'rake' # Tasks management
  gem 'rubocop', require: false # Ruby linter
  gem 'yard' # Documentation tool
end

group :development, :test do
  gem 'byebug'
  gem 'dotenv', require: 'dotenv/load'
  gem 'guard-rspec', require: false
end

group :test do
  gem 'rack-test'
  gem 'rspec'
end
