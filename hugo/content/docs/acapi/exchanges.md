---
title: Exchanges
mermaid: true

---

This page documents the structure of exchanges used for broadcasting and routing of messages via AMQP in the existing ACAPI gem.

There are several variables in the exchange configurations below, denoted by curly braces:
1. `site` - the client site, such as 'dc0', 'me0', etc.
2. `env` - the environment name, such as 'qa', 'preprod', etc.

## Event Exchanges

Event exchanges begin at the fanout exchange and are copied via Exchange-to-Exchange bindings to other exchanges.

The event exchanges, publishers, and subscribers follow the following conventions:
1. Clients create bindings for their own queues from the various 'client' exchanges based on what messaging patterns they would like to use to filter the messages they would like to receive.
2. All events are published to the Fanout exchange.  This allows all interested clients to receive a copy if they wish, and allows the routing fabric and clients to customize message subscription.

{{<mermaid align="left">}}
graph LR;
  Events{"All Published Events"} --> Fanout["{site}.{env}.e.fanout.events"];
  Fanout --> Topic["{site}.{env}.e.topic.events"];
  Fanout --> Header["{site}.{env}.e.header.events"];
  Fanout --> Direct["{site}.{env}.e.direct.events"];
  Fanout --> AllMessageClients[Clients who want all events, like Graylog];
  Topic --> WCardClients[Clients who accept events with wildcard routing keys];
  Header --> HClients["Clients who accept events by matching header values"];
  Direct --> DClients["Clients who accept events by exact routing key match"];
{{< /mermaid >}}

## Request Exchanges

Request exchanges and routing exist to handle RPC type requests for things such as resources or entities.  They are used when ideally only a single subscriber should reply to a given request.

Request exchanges begin at the fanout exchange and are copied via Exchange-to-Exchange bindings to other exchanges.

Whenever possible, events should be used instead of request-reply sematics.

The request exchanges, publishers, and subscribers follow the following conventions:
1. Clients create bindings for their own queues from the various 'client' exchanges based on what messaging patterns they would like to use to filter the messages they would like to receive.
2. Only one client should be in charge of responding to a particular kind of request
3. For the same reasons as the event fanout exchange, all requests are published to the request Fanout exchange.

{{<mermaid align="left">}}
graph LR;
  Events{"All Published Requests"} --> Fanout["{site}.{env}.e.fanout.requests"];
  Fanout --> Topic["{site}.{env}.e.topic.requests"];
  Fanout --> Header["{site}.{env}.e.header.requests"];
  Fanout --> Direct["{site}.{env}.e.direct.requests"];
  Fanout --> AllMessageClients[Clients who want all requests, usually ONLY Graylog];
  Topic --> WCardClients[Clients who accept requests with wildcard routing keys];
  Header --> HClients["Clients who accept requests by matching header values"];
  Direct --> DClients["Clients who accept requests by exact routing key match"];
{{< /mermaid >}}
