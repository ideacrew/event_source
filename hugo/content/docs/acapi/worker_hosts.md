---
title: Worker Hosts
description: Describes how client workers are run and managed.

---

By itself, Ruby and the Ruby RabbitMQ client libraries provide no hosting environment under which to run client worker processes.

In the world of HTTP servers, worker processes are hosted using an HTTP Application Server such as Unicorn.

In the case of ACAPI, hosting of AMQP client worker processes is provided using the Sneakers library in combination with Server Engine, a gem for hosting non-HTTP worker processes derived from Unicorn.

This toolkit provides:
1. Automated respawn of clients upon process death.
2. Forking and shared memory for AMQP clients operating under a shared supervisor.
3. Client process count configuration, allowing for example, ACAPI to run 3 clients of type X while running 2 clients of type Y.
