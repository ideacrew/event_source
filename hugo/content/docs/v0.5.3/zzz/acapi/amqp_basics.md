---
title: AMQP Basics
mermaid: truet
description: "Describes basic concepts in AMQP."

---

AMQP message publishing and consumption at it's heart consists of three concepts: Exchanges, Queues, and Bindings.

These concepts and how they operate are non-configurable and are core concepts of RabbitMQ/AMQP.

Messages are published to Exchanges.

Messages are consumed from Queues.

Messages are routed from Exchanges to Queues using Bindings.

The **kind** of Exchange determines the kind of bindings that may be created between that exchange and a queue:
1. Fanout exchanges don't care about any details of the binding, any bound queue will get all messages.
2. Topic exchanges select messages for bound queues based on matching the message routing key against a pattern expression.
3. Direct exchanges select messages for bound queues based on the exact match of a message routing key.
4. Header exchanges select messages for bound queues based on a single or set of header values.  Bindings against header exchanges can be configured to be 'all', or 'any' in terms of how many header values in the binding must match.

Exchange to Exchange bindings are also available for routing between exchanges, and are subject to the same rules for message selection on the 'source' exchange as creating a binding between the source exchange and a queue would be.
