# frozen_string_literal: true

# Persist class are responsible for writing into the database
module Persist
  # Point is the only persist class for this simple app
  # When there will be more model, depency to database and interface
  # should be extracted to a parent class
  class Point
    include Database

    attr_reader :attribute

    # Persist object must receive attributes
    # in the case of Point, there is only one attribute
    def initialize(attribute)
      @attribute = attribute
    end

    # Save the point into tables points
    def create
      points.insert(coordinates: attribute)
    end

    private

    # Alias for the dataset of points
    def points
      db[:points]
    end
  end
end
