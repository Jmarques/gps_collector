# frozen_string_literal: true

# Handle Request and return Response
module Controller
  require_relative 'gps_controller_create'
  require_relative 'gps_controller_index'

  # Handle requests for GPS
  # Responsible to validate the parameter
  #
  # Call are embeded in a transaction
  # All public methods from a controller must return a rack response
  class GpsController
    include Database
    include Controller::GpsControllerCreate
    include Controller::GpsControllerIndex

    attr_reader :request

    # Initialize the controller with a request
    #
    # @param request [Rack::Request] Request from rack Rack::Request.new(env)
    def initialize(request)
      @request = request
    end

    private

    # To make sure we are not saving a subset of points if the rest of the set fails
    # We are wrapping all controller calls into a transaction
    #
    # We are also catching all known errors into a human readable response
    # the last line of the given block must be a rack response
    #
    # @return [Array<Integer, Hash, String>] Status, Header, Body
    def in_request(&block)
      db.transaction { block.call }
    rescue Error::ParamsError, Sequel::DatabaseError => e
      Helper::RackResponse.respond_with(422, message: { error: e.message })
    rescue JSON::ParserError => _e
      Helper::RackResponse.respond_with(422, message: { error: 'Parameters not formated properly' })
    end

    # Extract the parameters from the Rack::Request
    # @return [Hash]
    def params
      @params ||= JSON.parse(request.body.read)
    end
  end
end
