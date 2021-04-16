# frozen_string_literal: true

module EventSource
  module AsynApi
    # Allows the definition of input and output data types. These types can be objects,
    # but also primitives and arrays. This object is a superset of the
    # JSON Schema Specification Draft 07
    class Schema < Dry::Struct
    end
  end
end
