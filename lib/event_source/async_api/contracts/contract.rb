# frozen_string_literal: true

module EventSource
  module AsyncApi
    module Contracts
      # Configuration values and shared rules and macros for domain model validation contracts
      class Contract < Dry::Validation::Contract
        config.messages.default_locale = :en

        # config.messages.backend = :i18n
        # config.messages.default_locale - default I18n-compatible locale identifier
        # config.messages.backend - the localization backend to use. Supported values are: :yaml and :i18n
        # config.messages.load_paths - an array of files paths that are used to load messages
        # config.messages.top_namespace - the key in the locale files under which messages are defined, by default it's dry_validation
        # config.messages.namespace - custom messages namespace for a contract class. Use this to differentiate common messages

        # @!macro [attach] rulemacro
        #   Validates a nested hash of $1 params
        #   @!method $0($1)
        #   @return [Dry::Monads::Result::Success] if nested $1 params pass validation
        #   @return [Dry::Monads::Result::Failure] if nested $1 params fail validation
        rule(:components).each do
          next unless key? && value
          result = ComponentContract.new.call(value)

          # Use dry-validation metadata form to pass error hash along with text to calling service
          next unless result&.failure?
          key.failure(text: 'invalid component hash', error: result.errors.to_h)
        end

        rule(:info) do
          if key? && value
            result = InfoContract.new.call(value)

            # Use dry-validation metadata form to pass error hash along with text to calling service
            if result&.failure?
              key.failure(
                text: 'invalid info hash',
                error: result.errors.to_h
              )
            end
          end
        end

        rule(:servers).each do
          next unless key? && value
          result = ServerContract.new.call(value)

          # Use dry-validation metadata form to pass error hash along with text to calling service
          next unless result&.failure?
          key.failure(text: 'invalid server hash', error: result.errors.to_h)
        end

        rule(:tags) do
          next unless key? && value

          tags =
            value.inject([]) do |data, tag|
              result = TagContract.new.call(tag)

              # Use dry-validation metadata form to pass error hash along with text to calling service
              if result.success?
                data << result.to_h
              else
                key.failure(text: 'invalid tag hash', error: result.errors.to_h)
              end
              data
            end

          values.data.merge!(tags: tags) unless tags.empty?
          values
        end

        rule(:external_docs).each do
          next unless key? && value
          result = ExternalDocumentationContract.new.call(value)

          # Use dry-validation metadata form to pass error hash along with text to calling service
          next unless result&.failure?
          key.failure(
            text: 'invalid external_doc hash',
            error: result.errors.to_h
          )
        end
      end
    end
  end
end
