## Changes between EventSource 0.4.0 and 0.5.0 (June 3, 2021)

### Added support for HTTP protocol

EventSource now supports HTTP protocol.

### Added resiliancy to AMQP protocol

Improvements to the DSL removed references to AMQP protocol-specific objects in the
adapter methods. Spec coverage was broadened to verify additional scenarios.

## Changes between EventSource 0.3.0 and 0.4.0

EventSource now supports 'Connection by Configuration'. Using injected configuration
settings, EventSource is able to connect and exchange messages with network services.

The interface is based on [AsyncAPI specification 2.0.0](https://www.asyncapi.com/docs/specifications/2.0.0#channelsObject) which provides a model for representing many
common message exchange protocols. The interface applies the Adapter development
pattern to pave the way to efficiently add more protocols in the future.

### Added Support for AMQP

EventSource added network-based service-to-service eventing and message exchange using RabbitMQ.

### Initialization File

EventSource now uses a configuration file to set up a customized environment. For
example, the following file loads the AMQP protocol, sets the path where publish and
subscriber files may be found to: `app/eventsource` and loads the array: `NetworkServices`
holding AsyncApi-formatted YAML files with service connection information.

```ruby
# config/initializers/event_source.rb

config.protocols = %w[amqp]
config.pub_sub_root = Rails.root.join('app', 'event_source')
config.asyncapi_resources =
  EventSource::AsyncApi::Operations::Channels::Load
    .new
    .call(NetworkedServices)
    .value!
```

## Changes between EventSource 0.2.0 and 0.3.0 (April 20, 2021)

### Established a DSL and conventions for Eventing

### Add Support for QBus
