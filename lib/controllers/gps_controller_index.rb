# frozen_string_literal: true

module Controller
  # Manage the index action of GpsController
  module GpsControllerIndex
    # Radius allowed unit
    SUPPORTED_UNIT = %w[meter foot].freeze
    # Convertion ratio of foot into meter
    FOOT_TO_METER = 0.3048

    # Find points within parameters
    # There is 2 possible way to query points.
    #
    # The first is by providing a geometry of type point and a radius.
    # Radius length is mandatory.
    # Unit is optional and default to meters.
    # Unit can either be `feet` or `meter`.
    #
    # @example Geometry Point and a radius
    #   {
    #     'geometry':
    #       {
    #         'type': 'Point',
    #         'coordinates': [1.0, 1.0],
    #       },
    #     'radius': {
    #       'length': 2000,
    #       'unit': 'meter'
    #     }
    #   }
    #
    # The second is to provide a geometry of type polygon
    #
    # @example Geometry Point and a radius
    #   {
    #     'geometry':
    #       {
    #         'type': 'Polygon',
    #         'coordinates': [
    #           [1.0, 0.0],
    #           [1.0, 1.0],
    #           [0.0, 0.0],
    #           [0.0, 1.0]
    #         ]
    #       }
    #   }
    #
    # @return [Array<Integer, Hash, String>] Status, Header, Body
    def index
      in_request do
        validate_index_params(params)

        points =
          case params['geometry']['type']
          when 'Point' then points_within_radius(params)
          when 'Polygon' then points_within_polygon(params)
          end

        points_json = points.map { |point| Helper::RGeoDecoder.to_geojson(point) }

        Helper::RackResponse.respond_with(200, message: points_json)
      end
    end

    private

    def points_within_polygon(params)
      Repository::PointRepository.within_polygon(params['geometry']['coordinates'])
    end

    # Get the points from the radius
    #
    # @return [Sequel::Postgres::DataSet]
    def points_within_radius(params)
      lat = params['geometry']['coordinates'][0]
      long = params['geometry']['coordinates'][1]
      radius = params['radius']['length']

      radius *= FOOT_TO_METER if params['radius']['unit'] == 'feet'

      Repository::PointRepository.within_radius(latitude: lat, longitude: long, radius: radius)
    end

    # Validate the formating of parameter for the index call.
    # Validate for point radius and polygon
    #
    # @return [True]
    def validate_index_params(index_params)
      raise Error::ParamsError, 'Expecting Hash' unless index_params.is_a?(Hash)
      raise Error::ParamsError, 'Parameter `geometry` was not found' unless index_params.key?('geometry')
      raise Error::ParamsError, 'Parameter `type` was not found' unless index_params['geometry'].key?('type')

      validate_coordinates(index_params)

      case index_params['geometry']['type']
      when 'Point' then validate_index_point_params(index_params)
      when 'Polygon' then validate_index_polygon_params(index_params)
      else raise Error::ParamsError, "Unsuported Geometry `type` #{params['geometry']['type']}"
      end

      true
    end

    def validate_coordinates(index_params)
      geo_params = index_params['geometry']
      raise Error::ParamsError, 'Parameter `coordinates` was not found' unless geo_params.key?('coordinates')
      raise Error::ParamsError, 'Expecting `coordinates` to be an array' unless geo_params['coordinates'].is_a?(Array)
    end

    # Specific Validation for point radius
    def validate_index_point_params(index_params)
      if index_params['geometry']['coordinates'].any? { |coordinate| !coordinate.is_a?(Numeric) }
        raise Error::ParamsError, 'Expecting `coordinates` to be an array of numerics'
      end

      validate_index_radius_params(index_params)
    end

    def validate_index_radius_params(index_params)
      raise Error::ParamsError, 'Parameter `radius` was not found' unless index_params.key?('radius')
      # raise Error::ParamsError, 'Parameter `length` was not found' unless index_params['radius'].key?('length')

      return unless params['radius']['unit']
      return if SUPPORTED_UNIT.include?(params['radius']['unit'])

      raise Error::ParamsError, "Unknown unit `#{params['radius']['unit']}`, please use #{SUPPORTED_UNIT.join(', ')}"
    end

    # Specific Validation for polygon
    def validate_index_polygon_params(index_params)
      return unless index_params['geometry']['coordinates'].any? { |coordinate| !coordinate.is_a?(Array) }

      raise Error::ParamsError, 'Expecting `coordinates` to be an array of array'
    end
  end
end
