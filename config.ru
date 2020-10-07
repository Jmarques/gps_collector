# frozen_string_literal: true

require 'json'

# Handle agregation of GPS points and find points within a geometry
# Respond with JSON
#
class GpsCollector
  def call(env)
    request = Rack::Request.new(env)

    return respond_with(404) unless request.path_info == '/'

    [200, header, [{ message: 'Hello World' }.to_json]]
  end

  private

  def respond_with(error_code)
    message =
      case error_code
      when 404 then 'Page not found'
      else respond_with(404)
      end

    [error_code, header, [{ error: message }.to_json]]
  end

  def header
    { 'Content-Type' => 'application/json' }
  end
end

run GpsCollector.new
