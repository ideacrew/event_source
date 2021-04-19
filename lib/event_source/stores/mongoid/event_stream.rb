# frozen_string_literal: true

# Mongoid-based implementation of Martin Fowler's Event Sourcing Pattern where
# application state is a result of sequence of events.
# Based on Philippe Creux project at Kickstarter
# See: https://www.youtube.com/watch?v=ulF6lEFvrKo&list=PLE7tQUdRKcyaOq3HlRm9h_Q_WhWKqm5xc&index=30

# All Events inherit from this base class.
# It defines setters and accessors for the defined `data_attributes`
# After create, it calls `apply` to apply changes.

module EventSource
  # Event Stream interface
  class EventStream
    include Mongoid::Document
    include Mongoid::Timestamps
    include Dry::Monads::Result::Mixin

    belongs_to  :event_stream,
                polymorphic: true,
                inverse_of: :events

    index({ event_stream_id: 1 })
    index({ event_stream_type: 1 })

    # Model attributes with changed state values
    field :data,      type: Hash, default: {}

    # Attributes associated with the state value changes
    # For example: info available from controllers (e.g. submitted_at,
    # user, device, ip address)
    field :metadata,  type: Hash, default: {}

    scope :recent_first, -> { reorder('created_at DESC') }

    after_initialize do
      preset_source_model
    end

    before_create     :apply_and_persist
    after_create      :dispatch

    # Apply the event to the source_model passed in.
    # Must return the source_model.
    def apply(source_model)
      raise NotImplementedError
    end

    def source_model=(model)
      model.events << self
    end

    alias source_model event_stream

    def self.module_parent
      list = self.to_s.split('::')
      if list.size > 1
        parents = list.slice(0, list.size - 1)
        parents.join('::').constantize
      else
        list.size == 1 ? self : nil
      end
    end

    # Instantiate an instance of the source model
    def build_source_model
      module_name.const_get(source_model_name).new
    end

    # Define attributes to be serialized in the `data` column.
    # It generates setters and getters for those.
    #
    # Example:
    #
    # class MyEvent < Event
    #   data_attributes :title, :description
    # end
    #
    # MyEvent.create!
    def self.data_attributes(*attrs)
      @data_attributes ||= []

      attrs.map(&:to_s).each do |attr|
        @data_attributes << attr unless @data_attributes.include?(attr)

        define_method attr do
          self.data ||= {}
          self.data[attr]
        end

        define_method "#{attr}=" do |arg|
          self.data ||= {}
          self.data[attr] = arg
        end
      end

      @data_attributes
    end

    # The model associated with this event.  Uses the convention that the Event
    # class is in the model's namespace and that the model name is the same name
    # as namespace in singular form.  For example:
    #   module_name       => Organizations
    #   model_class_name  => Organization
    def self.module_name
      self.module_parent
    end

    def self.source_model_name
      module_name.name.singularize
    end

    delegate :source_model_name, :module_name, to: :class

    # Underscored class name by default. ex: "post/updated"
    # Used when sending events to the data pipeline
    def self.event_name
      self.name.underscore
    end

    private

    # Build source_model when the event is creating a source_model
    def preset_source_model
      self.source_model ||= build_source_model
    end

    # Apply the transformation to the source_model and save it
    def apply_and_persist
      # Subclasses must define the `apply` method.
      # Apply!
      apply(source_model)

      # Persist!
      if source_model.save
        Success(source_model)
      else
        Failure(source_model.messages)
      end
    end

    def dispatch
      Dispatcher.dispatch(self)
    end
  end
end
