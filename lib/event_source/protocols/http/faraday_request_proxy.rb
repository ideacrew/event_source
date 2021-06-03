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

        attr_reader :channel_proxy, :subject, :name

        # @param channel_proxy [EventSource::Protocols::Http::FaradayChannelProxy] Http Channel proxy
        # @param async_api_channel_item [Hash] channel_bindings Channel definition and bindings
        # @return [Faraday::Request]
        def initialize(channel_proxy, async_api_channel_item)
          @channel_proxy = channel_proxy
          @name = channel_proxy.name
          request_bindings = async_api_channel_item[:publish][:bindings][:http]
          @subject = faraday_request_for(request_bindings)
        end

        # Faraday::Request.body
        # Faraday::Request.headers
        # Faraday::Request.http_method
        # Faraday::Request.options
        # Faraday::Request.params
        # Faraday::Request.path

        # Execute the HTTP request
        # @param [Mixed] payload event message content
        # @param [Hash] bindings AsyncAPI HTTP message bindings
        # @return [Faraday::Response] response
        def publish(payload: nil, bindings: {})
          faraday_publish_bindings = sanitize_bindings(bindings)
          @subject.body = payload if payload
          if faraday_publish_bindings[:headings]
            @subject.headers.update(faraday_publish_bindings[:headings])
          end

          # @subject.call(payload, faraday_publish_bindings)
          response = connection.builder.build_response(connection, @subject)
          logger.info "Executed Faraday request #{@subject.inspect}"
          @channel_proxy.enqueue(response)
          response
        end

        # Forwards all missing method calls to the Bunny::Queue instance
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
          method = bindings[:method].downcase.to_sym
          request =
            connection.build_request(method) { |req| req.path = request_path }

          logger.info "Created Faraday request #{request}"
          request
        end

        def sanitize_bindings(bindings)
          return {} unless options.present?
          options = bindings[:http]
          operation_bindings[:headers] = options[:headers] if options[:headers]
          operation_bindings
        end
      end
    end
  end
end
