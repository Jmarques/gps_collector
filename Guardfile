# frozen_string_literal: true

guard :rspec, cmd: 'rspec' do
  watch(%r{^spec/.+_spec\.rb$})
  watch(%r{^lib/(.+)\.rb$}) { |m| "spec/#{m[1]}_spec.rb" }
  watch('lib/controllers/gps_controller_create.rb') { 'spec/controllers' }
  watch('lib/controllers/gps_controller_index.rb') { 'spec/controllers' }
  watch('spec/spec_helper.rb') { 'spec' }
  watch('gps_collector.rb') { 'spec/controllers' }
end
