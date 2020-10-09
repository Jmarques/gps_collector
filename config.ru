# frozen_string_literal: true

require 'logger'
logger = ::Logger.new(STDOUT)

# use Rack::CommonLogger, logger
# use Rack::Lint

require_relative 'gps_collector'
run GpsCollector.new(logger)
