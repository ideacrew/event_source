# frozen_string_literal: true

require 'nokogiri'

module EventSource
  module Protocols
    module Http
      module Soap
        module Operations
          # Encode Security Values and a Body into a single SOAP payload.
          #
          # This operation simply encodes already generated security
          # information, and probably isn't what you want to call directly.
          class EncodeSoapPayload
            send(:include, Dry::Monads[:result, :do])

            # Take a set of security token values and a payload and wrap it in
            # a top level SOAP XML.  This assumes you have pre-validated your
            # XML and it is valid.
            # @param [Hash] opts the parameters for the operation
            # @option opts [String] :body XML body payload you want to wrap
            # @option opts [
            #                 ::EventSource::Protocols::Http::Soap::UsernameTokenValues
            #               ] :username_token_values the token values for SOAP security
            # @return [Dry::Result<String>] the new soap payload
            def call(opts)
              params = yield validate_params(opts)
              encode_soap_xml(params[:username_token_values], params[:body])
            end

            protected

            def validate_params(opts)
              validation_result = Soap::Contracts::EncodeSoapPayloadOperationContract.new.call(
                opts
              )
              validation_result.success? ? Success(validation_result.values) : Failure(validation_result.errors)
            end

            def encode_soap_xml(security_values, body)
              builder = Nokogiri::XML::Builder.new do |xml|
                xml[:soap].Envelope({ "xmlns:soap" => Soap::XMLNS["soap"] }) do |envelope|
                  encode_security_header(envelope, security_values)
                  encode_body(envelope, body)
                end
              end
              Success(builder.to_xml)
            end

            def encode_security_header(envelope, security_values)
              envelope[:soap].Header do |header|
                header[:wsse].Security({
                                         "xmlns:wsse" => Soap::XMLNS["wsse"],
                                         "xmlns:wsu" => Soap::XMLNS["wsu"]
                                       }) do |security|
                  # wsse:UsernameToken wsu:Id="UsernameToken-73590BD4745C9F3F7814189343300461"
                  security[:wsse].UsernameToken do |ut|
                    ut[:wsse].Username security_values.username
                    ut[:wsse].Password({
                                         "Type" => security_values.digest_encoding
                                       }, security_values.password_digest)
                    ut[:wsse].Nonce({
                                      "EncodingType" => Soap::USERNAME_TOKEN_BASE64_ENCODING_VALUE
                                    }, security_values.encoded_nonce)
                    ut[:wsu].Created security_values.created_value
                  end
                end
              end
            end

            def encode_body(envelope, xml_body)
              envelope[:soap].Body do |body|
                body << xml_body
              end
            end
          end
        end
      end
    end
  end
end