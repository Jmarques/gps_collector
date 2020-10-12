# frozen_string_literal: true

require 'logger'
logger = ::Logger.new($stdout)

require_relative 'gps_collector'
run GpsCollector.new(logger)
