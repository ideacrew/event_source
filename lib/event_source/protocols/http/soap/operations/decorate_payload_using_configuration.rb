# frozen_string_literal: true

require 'nokogiri'

module EventSource
  module Protocols
    module Http
      module Soap
        module Operations
          # Given an XML body and a security configuration, decorate the XML
          # with all the required goodies to make it a valid SOAP payload.
          #
          # This takes as input the security configuration and the XML body,
          # and is what you want to use to 'wrap up' a soap request.
          class DecoratePayloadUsingConfiguration
            send(:include, Dry::Monads[:result, :do])

            # Convert a security config and a body into a SOAP payload.
            # This assumes you have pre-validated your XML and it is valid.
            # @param [Hash] opts the parameters for the operation
            # @option opts [String] :body XML body payload you want to wrap
            # @option opts [
            #                 ::EventSource::Protocols::Http::Soap::SecurityHeaderConfiguration
            #               ] :security_settings the security options for the SOAP request
            # @return [Dry::Result<String>] the wrapped soap payload
            def call(opts)
              params = yield validate_params(opts)
              security_tokens = yield build_header_tokens_from_configuation(params[:security_settings])
              encode_payload(security_tokens, params[:body])
            end

            protected

            def validate_params(opts)
              validation_result = Soap::Contracts::DecoratePayloadUsingConfigurationOperationContract.new.call(
                opts
              )
              validation_result.success? ? Success(validation_result.values) : Failure(validation_result.errors)
            end

            def build_header_tokens_from_configuation(security_config)
              GenerateUsernameTokenComponents.new.call(security_config)
            end

            def encode_payload(security_tokens, body)
              EncodeSoapPayload.new.call(
                body: body,
                username_token_values: security_tokens
              )
            end
          end
        end
      end
    end
  end
end