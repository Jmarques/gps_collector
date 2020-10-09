# frozen_string_literal: true

source 'https://rubygems.org'

gem 'dotenv-rails' # Allow loading .env into ENV in development
gem 'json'
gem 'pg' # Postgresql
gem 'rgeo-geojson' # Provides GeoJSON encoding and decoding
gem 'sequel' # Simple SQL database access toolkit

group :development do
  gem 'rake'
  gem 'rubocop', require: false # Ruby linter
  gem 'yard'
end

group :development, :test do
  gem 'byebug'
  gem 'dotenv'
end
