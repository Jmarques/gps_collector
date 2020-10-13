# frozen_string_literal: true

task :load_app do
  require_relative 'gps_collector'
end

namespace 'db' do
  desc 'Create empty tables'
  task create: :load_app do
    Database.db.create_table(:points) do
      primary_key(:id)
      column(:coordinates, 'geography(POINT, 4326)')
      index :coordinates, type: :gist
    end
  end

  desc 'Destroy all tables'
  task drop: :load_app do
    Database.db.drop_table(:points)
  end
end

namespace 'doc' do
  require 'yard'

  YARD::Rake::YardocTask.new do |t|
    t.files = ['lib/**/*.rb', 'gps_collector.rb']
  end

  desc 'Generate documentation'
  task create: 'doc:yard'
end

namespace 'linter' do
  require 'rubocop/rake_task'

  RuboCop::RakeTask.new

  desc 'Run Linter'
  task run: 'linter:rubocop'
end

namespace 'specs' do
  require 'rspec/core/rake_task'
  RSpec::Core::RakeTask.new(:spec)

  desc 'Run all tasks'
  task all: 'specs:spec'
end

desc 'Linter, Specs, Documentation'
task validate: ['linter:run', 'specs:all', 'doc:create']
