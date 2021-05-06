---
title: Clients
mermaid: truet

---

This page documents the conventions surrounding subscribers within the ACAPI gem.

It should be noted that the direct creation of most binding and queues for clients is not done directly, the ACAPI gem handles it automatically (in the case of ACAPI the Sneakers framework handles this for us).

## Event Message Subscribers

Event clients subscribe to desired event messages by:
1. Creating a client queue from which to process messages.
2. Creating a binding between their queue and one or more of the desired client [Exchanges](../exchanges) for events.

## Request/Reply Subscribers

Request/Reply clients subscribe to desired request messages by:
1. Creating a client queue from which to process messages.
2. Creating a binding between their queue and one or more of the desired client [Exchanges](../exchanges) for requests.

Replying to a request consists of the 'dynamic queue' convention for RabbitMQ message replies:
1. The client who made the request has created a dynamic queue for the purpose of receiving the specific reply to the specific request.
2. The client who made the request has provided the name of the dynamic queue in the "reply_to" property of the request message.
3. Replying client publishes the response message to the RabbitMQ 'default exchange' with a routing key matching the 'reply_to' value of the request message.  The RabbitMQ default exchange routes any message published to it to a queue of exactly the same name is the routing key of the message.

## Message Retry

Note that while this section describes the implementation of message retry in clients, this is usually automatically performed by the gem (again using the Sneakers framework, in the case of ACAPI).

**TODO: EXPLAIN RETRY MECHANISM**
