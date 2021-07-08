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
          @request_content_type =
            EventSource::ContentTypeResolver.new(
              'application/json',
              @channel_item.publish
            )
          @response_content_type =
            EventSource::ContentTypeResolver.new(
              'application/json',
              @channel_item.subscribe
            )
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
        def publish(payload: nil, publish_bindings: {}, headers: {})
          faraday_publish_bindings = sanitize_bindings(publish_bindings)
          faraday_publish_bindings[:headers] = (faraday_publish_bindings[:headers] || {}).merge(headers)
          text_payload =
            (@request_content_type.json? ? payload.to_json : payload) if payload
          text_payload ||= ''
          @subject.body = text_payload
          if faraday_publish_bindings[:headers]
            @subject.headers.update(faraday_publish_bindings[:headers])
          end
          logger.debug "Faraday request headers: #{@subject.headers}"
          logger.debug "FaradayExchange#publish  connection: #{connection.inspect}"
          logger.debug "FaradayExchange#publish  processing request with headers: #{@subject.headers} body: #{@subject.body}"

          response = connection.builder.build_response(connection, @subject)
          logger.debug "Executed Faraday request...response: #{response.status}"

          attach_payload_correlation_id(response, text_payload, payload)
          logger.debug "FaradayRequest#publish  response headers: #{response.headers}"

          @channel_proxy.enqueue(response)
          logger.debug 'FaradayRequest#publish response enqueued.'
          response
        end

        def attach_payload_correlation_id(response, text_payload, payload)
          payload_correlation_id =
            JSON.parse(text_payload)['CorrelationID'] if @request_content_type
            .json? && payload
          response.headers.merge!(
            'CorrelationID' =>
              (payload_correlation_id || generate_correlation_id)
          )
        end

        def generate_correlation_id
          "#{Kernel.rand}-#{Time.now.to_i * 1000}-#{Kernel.rand(999_999_999_999)}"
        end

        def respond_to_missing?(name, include_private); end

        def method_missing(name, *args)
          @subject.send(name, *args)
        end

        private

        def connection
          channel_proxy.connection
        end

        def request_path
          channel_proxy.name
        end

        def faraday_request_for(bindings)
          method = bindings ? bindings[:method].downcase.to_sym : :get
          request =
            connection.build_request(method) do |req|
              req.path = request_path.to_s.match(/\/?(.*)/)[1]
            end

          logger.info "Created Faraday request #{request}"
          request
        end

        def sanitize_bindings(bindings)
          return {} unless bindings.present?
          options = bindings[:http]&.deep_symbolize_keys || {}
          operation_bindings = {}
          operation_bindings[:headers] = options[:headers] if options
            .respond_to?(:headers)
          operation_bindings
        end
      end
    end
  end
end