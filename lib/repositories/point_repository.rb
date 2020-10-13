# frozen_string_literal: true

# Handle the application data directly from database
module Repository
  # Repository for points
  # Manage the Postgresql and PostGis SQL call to return datasets
  class PointRepository
    extend Database

    # Find the point within a specified distance of given coordinates
    #
    # @param latitude [Float]
    # @param longitude [Float]
    # @param radius [Integer] radius in meters
    #
    # @return [Sequel::Postgres::DataSet]
    def self.within_radius(latitude:, longitude:, radius: 1000)
      db[<<~SQL]
        SELECT
            points.*
          , ST_X(points.coordinates::geometry) AS longitude
          , ST_Y(points.coordinates::geometry) AS latitude
        FROM points
        WHERE ST_DWithin(points.coordinates, ST_MakePoint(#{longitude},#{latitude})::geography, #{radius})
      SQL
    end

    # Find the point within a polygon
    #
    # @param coordinates Array<[Float]>
    #
    # @return [Sequel::Postgres::DataSet]
    def self.within_polygon(coordinates)
      coordinate_sql =
        coordinates
        .map { |coordinate| "#{coordinate[0].to_f} #{coordinate[1].to_f}" }
        .join(', ')

      polygon_sql = "ST_GeomFromText('POLYGON((#{coordinate_sql}))', 4326)"

      db[<<~SQL]
        SELECT
            points.*
          , ST_X(points.coordinates::geometry) AS longitude
          , ST_Y(points.coordinates::geometry) AS latitude
        FROM points
        WHERE ST_Within(points.coordinates::geometry, #{polygon_sql})
      SQL
    end
  end
end
