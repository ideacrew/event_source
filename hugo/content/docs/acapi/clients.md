---
title: Clients
mermaid: true
description: Describes AMQP clients and their conventions.

---

This page documents the conventions surrounding subscribers within the ACAPI gem.

It should be noted that the direct creation of most binding and queues for clients is not done directly, the ACAPI gem handles it automatically (in the case of ACAPI the Sneakers framework handles this for us).

## Event Message Subscribers

Event clients subscribe to desired event messages by:
1. Creating a client queue from which to process messages.
2. Creating a binding between their queue and one or more of the desired client [Exchanges](../exchanges) for events.

Event clients are free to broadcast event in response to messages received, but should never send direct replies.

## Request/Reply Subscribers

Request/Reply clients subscribe to desired request messages by:
1. Creating a client queue from which to process messages.
2. Creating a binding between their queue and one or more of the desired client [Exchanges](../exchanges) for requests.

Replying to a request consists of the 'dynamic queue' convention for RabbitMQ message replies:
1. The client who made the request has created a dynamic queue for the purpose of receiving the specific reply to the specific request.
2. The client who made the request has provided the name of the dynamic queue in the "reply_to" property of the request message.
3. Replying client publishes the response message to the RabbitMQ 'default exchange' with a routing key matching the 'reply_to' value of the request message.  The RabbitMQ default exchange routes any message published to it to a queue of exactly the same name is the routing key of the message.

## Message Retry

ACAPI uses the RabbitMQ/AMQP standard method of implementing retries.

Note that while this section describes the implementation of message retry in clients, this is usually automatically performed by the gem (again using the Sneakers framework, in the case of ACAPI).

### Configuration

The standard retry method requires the following objects to be created:
1. Create a fanout 'retry' exchange for the client.
2. When creating the client queue, assign a dead-letter exchange using the `x-dead-letter-exchange` parameter - this should be the same name as the fanout 'retry' exchange.
3. Create a 'retry-requeue' fanout exchange for the client.
4. Create a 'retry' queue for the client, with the following properties:
  1. The dead-letter exchange should match the 'retry-requeue' fanout exchange name
  2. The `x-message-ttl` property of the queue should match the retry interval you want for this client, in milliseconds
5. Bind the 'retry' queue to the 'retry' exchange with a wildcard fanout binding '#'.
6. Create a fanout binding from the 'retry-requeue' exchange to your original client queue with a wildcard fanout binding '#'.
7. Create a client error queue and a fanout client error exchange.  Bind them with a wildcard fanout binding.

### Workflow

{{<mermaid align="left">}}
graph LR;
  CQueue[Client Queue] -->|4 - explicitly dead lettered| RetryExchange[Client Retry Exchange];
  CQueue -->|3 - max errors reached| ErrorExchange[Client Error Exchange];
  ErrorExchange -->|fanout binding| ErrorQueue[Client Error Queue];
  RetryExchange -->|5 - fanout binding| RetryQueue[Client Retry Queue];
  RetryQueue -->|6 - deadletter via ttl| RetryRequeueExchange[Client Retry/Requeue Exchange];
  RetryRequeueExchange -->|7 - fanout binding| CQueue;
{{< /mermaid >}}

The standard RabbitMQ/AMQP retry workflow consists of the following steps:
1. Consume the message from your client queue.
2. Upon an error, check for the presence and length of the `x-death` header in your message, the presence and number of entries in this header will tell you the number of previous retries.
3. If the previous retry threshold has been reached, republish the message to the client 'error' exchange and ack the message.  It will be routed to the error queue and the workflow is over.
4. If the retry threshold has not yet been met, **nack** the message with **requeue false**.  This automatically routes the message to the dead-letter exchange.
5. The message will be routed to the 'retry' queue via a fanout binding.
6. The retry queue will wait the configured amount of time before automatically dead-lettering the message, resulting in the message being published to the 'retry-requeue' exchange.
7. The fanout binding on the 'retry-requeue' exchange will route the message to the client queue for retry.

