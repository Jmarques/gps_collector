# frozen_string_literal: true

# Loading dependencies
require 'byebug'
require 'dotenv/load'
require 'json'
require 'pg'
require 'rgeo/geo_json'
require 'sequel'

# Loading GpsCollector files
require_relative 'lib/database'
Dir['lib/**/*.rb'].each { |file| require_relative file }

# Handle agregation of GPS points and find points within a geometry
# Respond with JSON
#
# Responsible to determine if the path and method is handled
# Pass the responsibility of handling the request to GpsController
#
class GpsCollector
  attr_reader :logger

  # Initialize the APP
  #
  # @param logger [Logger]
  def initialize(logger = ::Logger.new(STDOUT))
    @logger = logger
  end

  # Rake application call
  #
  # @param env [Hash] Request environment
  # @return [Array<Integer, Hash, String>] Status, Header, Body
  def call(env)
    request = Rack::Request.new(env)

    return Helper::RackResponse.respond_with(404) unless request.path_info == '/'

    case request.request_method
    when 'GET'  then Controller::GpsController.new(request).index
    when 'POST' then Controller::GpsController.new(request).create
    else Helper::RackResponse.respond_with(404)
    end
  rescue StandardError => e
    logger.fatal("Exception: #{e.class}\n#{e.message}")
    Helper::RackResponse.respond_with(500)
  end
end
