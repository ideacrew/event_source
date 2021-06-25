# frozen_string_literal: true

module EventSource
  module Protocols
    module Http
      # HTTP protocol Adapter pattern class for {EventSource::PublishOperation}
      # AsyncApi HTTP protocol specification includes Operation and Message
      # Bindings only.  Server and Channel Bindings are not supported at
      # Binding version 0.1.0
      # @example AsyncApi HTTP protocol bindings.
      # /determinations/eval
      #   publish:
      #     message:
      #       bindings:
      #         http:
      #           headers:
      #             type: object
      #             properties:
      #               Content-Type:
      #                 type: string
      #                 enum: ['application/json']
      #           bindingVersion: '0.1.0'
      #   subscribe:
      #     bindings:
      #       http:
      #         type: request
      #         method: GET
      #         query:
      #           type: object
      #           required:
      #             - companyId
      #           properties:
      #             companyId:
      #               type: number
      #               minimum: 1
      #               description: The Id of the company.
      #           additionalProperties: false
      #         bindingVersion: '0.1.0'
      class FaradayRequestProxy
        include EventSource::Logging

        attr_reader :channel_proxy, :subject, :name, :channel_item, :connection

        # @param channel_proxy [EventSource::Protocols::Http::FaradayChannelProxy] Http Channel proxy
        # @param async_api_channel_item [Hash] channel_bindings Channel definition and bindings
        # @return [Faraday::Request]
        def initialize(channel_proxy, async_api_channel_item)
          @channel_proxy = channel_proxy
          @name = channel_proxy.name
          @channel_item = async_api_channel_item
          request_bindings = async_api_channel_item.publish.bindings.http
          @request_content_type = EventSource::ContentTypeResolver.new("application/json", @channel_item.publish)
          @response_content_type = EventSource::ContentTypeResolver.new("application/json", @channel_item.subscribe)
          @subject = faraday_request_for(request_bindings)
        end

        # TODO: - update the payload arg to parse following components:
        # Faraday::Request.body
        # Faraday::Request.headers
        # Faraday::Request.options
        # Faraday::Request.params
        # Faraday::Request.path

        # Execute the HTTP request
        # @param [Mixed] payload request content
        # @param [Hash] publish_bindings AsyncAPI HTTP message bindings
        # @return [Faraday::Response] response
        def publish(payload: nil, publish_bindings: {})
          faraday_publish_bindings = sanitize_bindings(publish_bindings)
          text_payload = nil
          text_payload = (@request_content_type.json? ? payload.to_json : payload) if payload
          text_payload ||= ""
          @subject.body = text_payload
          @subject.headers.update(faraday_publish_bindings[:headers]) if faraday_publish_bindings[:headers]
          logger.debug "FaradayExchange#publish  connection: #{connection.inspect}"
          logger.debug "FaradayExchange#publish  processing request with headers: #{@subject.headers} body: #{@subject.body}"

          # @subject.call(payload, faraday_publish_bindings)
          response = connection.builder.build_response(connection, @subject)
          logger.debug "Executed Faraday request...response: #{response.status}"
       
          payload_correlation_id = nil
          if @request_content_type.json?
            payload_correlation_id = JSON.parse(text_payload)['CorrelationID'] if payload
          end
          response.headers.merge!('CorrelationID' => (payload_correlation_id || generate_correlation_id))
          logger.debug "FaradayRequest#publish  response headers: #{response.headers}"

          @channel_proxy.enqueue(response)
          logger.debug "FaradayRequest#publish response enqueued."
          response
        end

        def generate_correlation_id
          "#{Kernel.rand}-#{Time.now.to_i * 1000}-#{Kernel.rand(999_999_999_999)}"
        end

        def respond_to_missing?(name, include_private); end

        def method_missing(name, *args)
          @subject.send(name, *args)
        end

        private

        def connection_proxy
          channel_proxy.connection_proxy
        end

        def request_path
          connection_request_path = connection_proxy.request_path
          connection_request_path.blank? ? channel_proxy.name : connection_request_path
        end

        def faraday_request_for(bindings)
          method = bindings ? bindings[:method].downcase.to_sym : :get
          @connection = connection_proxy.build_connection_for_request(nil, nil, @request_content_type, @response_content_type)
          request =
            @connection.build_request(method) do |req|
              req.path = request_path.to_s
            end

          logger.info "Created Faraday request #{request}"
          request
        end

        def sanitize_bindings(bindings)
          return {} unless bindings.present?
          options = bindings[:http] || {}
          operation_bindings = {}
          operation_bindings[:headers] = options[:headers] if options[:headers]
          operation_bindings
        end
      end
    end
  end
end
