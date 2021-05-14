# frozen_string_literal: true
require 'base64'

module EventSource
  module Operations
    # Performs Base64 encoding and decoding.  Supports files and strings as input sources.
    class Codec64
      send(:include, Dry::Monads[:result, :do])
      send(:include, Dry::Monads[:try])

      # @param [Hash] opts the params to perform Base64 encoding and decoding
      # @option opts [String] :source_filename the source file to encode
      # @option opts [Binary, String] :source_value the source string to encode
      # @option opts [Symbol] :transform the operation to perform: :encode (default) or :decode
      # @return [Dry::Monad::Result, String] Encoded binary datum wrapped in Monad result
      def call(params)
        transformed_value = yield transform(params)

        Success(transformed_value)
      end

      private

      def transform(params)
        if params[:source_filename].present?
          transform_file(params)
        else
          transform_string(params)
        end
      end

      def transform_file(params)
        filename = params[:source_filename]
        if File.exists?(filename) && File.readable?(filename)
          encoded_string =
            File.open(filename, 'r') do |file|
              # Base64.strict_encode64(file.read)
              Base64.encode64(file.read)
            ensure
              file.close
            end
        else
          raise EventSource::Error::FileAccessError,
                "file not found or unable to read: #{filename}"
        end
        Success(encoded_string)
      end

      def transform_string(params)
        if params[:transform] && params[:transform].to_sym == :decode
          Try() { Base64.strict_decode64(params[:source_value]) }.to_result
        else
          Try() { Base64.strict_encode64(params[:source_value]) }.to_result
        end
      end
    end
  end
end
