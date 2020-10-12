# frozen_string_literal: true

require 'rack/test'
require_relative '../gps_collector'

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups

  config.include Rack::Test::Methods

  config.before(:each) do
    allow_any_instance_of(Persist::Point).to receive(:create).and_return(true)
  end
end
