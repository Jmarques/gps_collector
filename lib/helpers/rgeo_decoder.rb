# frozen_string_literal: true

# Provide sharable interface
module Helper
  # Interface between Rgeo and the rest of the app
  module RGeoDecoder
    # Decode Hash into PostGis compatible information
    #
    # @param attributes [Hash] Geometry Point information ex: {"type"=>"Points", "coordinates"=>[100.0, 0.0]}
    #
    # @return [String]
    def self.decode_point(attributes)
      raise ArgumentError, 'Unsuported coordinates' if attributes['coordinates']&.size != 2
      raise ArgumentError, 'Invalid coordinates' if attributes['coordinates'].any? { |coo| !coo.is_a?(Numeric) }

      "POINT(#{attributes['coordinates'][0].to_f} #{attributes['coordinates'][1].to_f})"
    end
  end
end
