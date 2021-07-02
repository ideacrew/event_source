---
title: AsyncAPI Differences
description: Areas where we differ from the AsyncAPI spec.

---

This document lists locations where our current object model differs from that presented in the AsyncAPI specification, and where possible, an explanation for why.  It also tracks any areas where we plan to address these differences.

## AMQP Bindings

1. The spec allows for bindings of exchanges and queues at the channel level only.  Currently in several of our configurations we are loading these at the operation level. - **If true, need to provide examples**
2. We have introduced a new binding option called 'routing_key' at the operation level.
3. Because of these AMQP bindings at the operation level are currently not strongly typed - they are a hash. - **This is a missing implementation detail, we should update these to be structs**

## Channel Bindings

Channel bindings are currently implemented as a hash, and are not strongly typed.  They also do not enforce the correct binding keys or values for the HTTP nor AMQP protocols. **This has been corrected for HTTP, still pending for AMQP**

## Servers

The security section for servers is currently implemented as a list of hashes.  It should be implemented as a list of security schema structs.

## Default Content Type

The top level `defaultContentType` specifier, while included in the model, is not propagated nor provided to adapters and proxies.  This means currently any custom content types need to be enacted through the message configuration.