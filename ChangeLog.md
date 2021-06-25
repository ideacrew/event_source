## Version 0.5.3

### SOAP Protocol Support Under HTTP

### Extended Protocol Bindings for Operations

Protocol Bindings for Operations have been moved to a Dry::Struct.  This is currently implemented only for HTTP, AMQP bindings are still treated as a hash.

### Difference Documentation

In areas where we differ from the AsyncAPI spec, I have introduced documentation identifying the differences.  It can currently be found in `hugo/content/docs/async_api_differences.md`.

### Thread Safety and Worker Pools/Hosts - but not yet

AMQP workers need some love around worker process hosting - planned for next release.

### Improved Single-Location Connection Configuration for DevOps

Connection redirection is complete.

If you would like to have a 'placeholder' URL in the yaml, and put the 'real' url in the ruby configuration file, set the server ref value to the URL in the yaml and make the host, url, port, or other values what you want them to be for the 'real' server:

Async API YAML:
```yaml
servers:
  production:
    url: http://aces-qa/some-random-lookup-uri
    protocol: http
    description: ACES QA Server
```

ruby configuration file:
```ruby
    server.http do |http|
      http.ref = "http://aces-qa/some-random-lookup-uri"
      http.url = "http://localhost:6767/"
    end
```

### File Loading

Correct file loading in AsyncApi namespace to use idiomatic ruby conventions and avoid unpredictable gem search paths when requiring files within the library.

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
