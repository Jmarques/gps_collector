# frozen_string_literal: true

# Handle Request and return Response
module Controller
  # Handle requests for GPS
  # Responsible to validate the parameter
  #
  # Call are embeded in a transaction
  # All public methods from a controller must return a rack response
  class GpsController
    include Database

    attr_reader :request

    # Initialize the controller with a request
    #
    # @param request [Rack::Request] Request from rack Rack::Request.new(env)
    def initialize(request)
      @request = request
    end

    # Register new points into the database.
    # The parameter must be an array of GeoJson Point or GeoJson GeometryCollection
    # Parameters are JSON
    #
    # @example Parameters for a single Point
    #   [{
    #     type: 'Point',
    #     coordinates: [100.0, 0.0]
    #   }]
    #
    # @example Parameters for a single GeometryCollection
    #   [{
    #     type: 'GeometryCollection',
    #     geometries: [
    #       {
    #          'type': 'Point',
    #          'coordinates': [100.0, 0.0]
    #       }, {
    #        'type': 'Point',
    #        'coordinates': [0.0, 100.0]
    #       }
    #     ]
    #   }]
    #
    # @example Parameters with a combination of Point and GeometryCollection
    #  [{
    #    type: 'Point',
    #    coordinates: [100.0, 0.0]
    #  },{
    #    type: 'GeometryCollection',
    #    geometries: [
    #      {
    #         'type': 'Point',
    #         'coordinates': [200.0, 0.0]
    #      }, {
    #       'type': 'Point',
    #       'coordinates': [0.0, 100.0]
    #      }
    #    ]
    #  }]
    #
    # @return [Array<Integer, Hash, String>] Status, Header, Body
    def create
      in_request do
        points = points_from_create_params(params)
        points.each do |point|
          # We are assuming that it's totally possible to have multiple points
          # with the same coordinates
          Persist::Point.new(point).create
        end

        Helper::RackResponse.respond_with(201, message: { success: "#{points.size} point(s) created" })
      end
    end

    # @return [Array<Integer, Hash, String>] Status, Header, Body
    def index
      Helper::RackResponse.respond_with(200)
    end

    private

    # Convert a hash of GeoJson into an array of PostGIS readable points
    #
    # @param params [Hash] The array of GeoJson to be translated
    # @return [Array<String>]
    def points_from_create_params(params)
      raise Error::ParamsError, 'Expecting array' unless params.is_a?(Array)

      params.map do |geo_param|
        validate_geo_param(geo_param)

        case geo_param['type']
        when 'Point' then Helper::RGeoDecoder.decode_point(geo_param)
        when 'GeometryCollection' then points_from_geometry_collection_params(geo_param)
        else raise Error::ParamsError, "Unsuported Geometry `type` #{geo_param['type']}"; end
      end.flatten
    # We are catching ArgumentError because Helper::RGeoDecoder.decode_point can raise
    rescue ArgumentError => e
      raise Error::ParamsError, e.message
    end

    # Validate a single geo param hash structure
    # @return [True]
    def validate_geo_param(param)
      raise Error::ParamsError, 'Expecting array of hashes' unless param.is_a?(Hash)
      raise Error::ParamsError, 'Parameter `type` was not found' unless param.key?('type')

      true
    end

    # Extract the GeoJson points inside a GeometryCollection
    #
    # @param collection_params [Hash]
    # @return [Array<String>]
    def points_from_geometry_collection_params(collection_params)
      raise Error::ParamsError, 'Expecting `geometries` attributes' unless collection_params.key?('geometries')
      raise Error::ParamsError, 'Expecting `geometries` to be Array' unless collection_params['geometries'].is_a?(Array)

      points_from_create_params(collection_params['geometries'])
    end

    # To make sure we are not saving a subset of points if the rest of the set fails
    # We are wrapping all controller calls into a transaction
    #
    # We are also catching all known errors into a human readable response
    # the last line of the given block must be a rack response
    #
    # @return [Array<Integer, Hash, String>] Status, Header, Body
    def in_request(&block)
      db.transaction { block.call }
    rescue Error::ParamsError => e
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
