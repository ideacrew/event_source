---
title: AyncAPI
---

EventSource's DSL applies the [AsyncAPi 2.0.0](https://www.asyncapi.com/docs/specifications/v2.0.0) specification for configuring the infrastucture environment and exchanging event messages. AsyncAPI settings include details that an application or service needs to:

1. Connect to a shared message broker/server
2. Produce messages for other services
3. Consume messages produced by other services

## AsyncApi Definition

Using AsyncAPI definitions, EventSource enables your application to join message broker- and Web server- hosted networks, registering as a message producer and/or consumer, performing message publish and subscribe operations. Components include:

- Servers
- Channels
- Operations
- Protocol-specific bindings at various levels

Following is an abbrevatiated example AsyncAPI YAML configuration file for accessing a service over HTTP protocol:

```yaml
servers:
  production:
    url: http://mitc:3001
    protocol: http
    protocolVersion: 0.1.0
    description: MitC Development Server

channels:
  /determinations/eval:
    publish:
      operationId: /determinations/eval
      description: HTTP endpoint for MitC eligibility determination requests
      bindings:
        http:
          type: request
          method: POST
          headers:
            Content-Type: application/json
            Accept: application/json
    subscribe:
      operationId: /on/determinations/eval
      description: EventSource Subscriber that publishes MitC eligibility determination responses
      bindings:
        http:
          type: response
          method: GET
          headers:
            Content-Type: application/json
            Accept: application/json
```

The `servers` section specifies Connection-level information, including the URL to the subject server and the protocol to use. Multiple server definitions may be defined, with the server key correlating with the associated Enivronment.

This example defines a server for the `production` environment. Typically the file will also include server references for `test` and `development` environments.

```yaml
servers:
  production:
    url: http://mitc:3001
    protocol: http
    protocolVersion: 0.1.0
    description: MitC Development Server
```

The `channels` section

## Organizing AsyncApi Definitions

An AsyncAPI definition can specify settings for a single messsage service using a single protocol. EventSource does support multiple AsyncAPI definitions for a single message resource. However, it's best to avoid splitting a single resource across multiple AsyncAPI definitions as it increases DevOps overhead and maintenance complexity.

For HTTP protocol, services with a host URL consistent across environment level (dev, test, production) and resource endpoints defined relative to that host may be represented in one AsyncAPI definition. In this case the server host specifies the EventSource Connection settings and each resource endpoint is represented by a Channel.

Similarly, a single AMQP message broker may define an EventSource Connection and each AMQP Channel is represented by an EventSource Channel.

That said, it's not uncommon for a service to load mulitple AsynCAPI definitions to support business functions. For example, a service may use AMQP to exchange messages within the enterprise boudaries and HTTP to access an external API service. A separate AsynAPI definition is necessary in this case because a single AyncAPI definition may describe only one protocol.

Another single service/multiple AsyncAPI definition scenario is when a service that accesses multple resources -- even though those services may use the same protocol. An AsyncAPI definition may specify settings for a single service only.
