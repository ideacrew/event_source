# frozen_string_literal: true

module EventSource
  module Configure
    module Operations
      # Validate the server configurations
      class ValidateServerConfigurations
        send(:include, Dry::Monads[:result, :do, :list, :validated])
        include EventSource::Logging

        # Validate the provided list of server configurations.
        def call(server_config)
          validate_configurations(server_config.configurations)
        end

        protected

        def validate_configurations(configs)
          validation_results = configs.map do |sc|
            validate_configuration(sc)
          end

          good, bad = validation_results.partition(&:success?)
          if bad.any?
            Failure(bad.map(&:failure))
          else
            Success(good.map(&:value!))
          end
        end

        def validate_configuration(sc)
          params_as_hash = sc.to_h
          case sc
          when ::EventSource::Configure::HttpConfiguration
            result = ::EventSource::Configure::Contracts::HttpConfigurationContract.new.call(params_as_hash)
            return Success(sc) if result.success?
            Failure([sc, result.errors])
          else
            Success(sc)
          end
        end
      end
    end
  end
end
