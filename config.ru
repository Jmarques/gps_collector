# frozen_string_literal: true

require 'logger'
logger = ::Logger.new($stdout)

use Rack::MethodOverride

require_relative 'gps_collector'
run GpsCollector.new(logger)
