# frozen_string_literal: true

module Controller
  # Manage the create action of GpsController
  module GpsControllerCreate
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
          # We are assuming that it's possible to have points
          # with the same coordinates
          Persist::Point.new(point).create
        end

        Helper::RackResponse.respond_with(201, message: { success: "#{points.size} point(s) created" })
      end
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
        when 'Point' then Helper::RGeoDecoder.to_sql(geo_param)
        when 'GeometryCollection' then points_from_geometry_collection_params(geo_param)
        else raise Error::ParamsError, "Unsuported Geometry `type` #{geo_param['type']}"; end
      end.flatten
    # We are catching ArgumentError because Helper::RGeoDecoder.to_sql can raise
    rescue ArgumentError => e
      raise Error::ParamsError, e.message
    end

    # Validate a single geo param hash structure
    #
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
  end
end
