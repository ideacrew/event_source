---
title: Outstanding Development Tasks
description: Features still to be delivered and improvements to be made.

---

## Documentation

Refactor documentation, in particular the ChangeLog, into a series of Hugo pages.  This will allow us to also put additional detail and instructions into each ChangeLog entry without overwhelming the reader.  If we would like, we can include select portions of the most recent or most important ChangeLog entries in the top-level page.

## AsyncAPI Support

1. Support for propagation of 'defaultContentType' from the top level AsyncAPI object down to channels and operations.
2. Extended binding support as a series of objects rather than just hashes for non-HTTP protocols.

Most issues or missing functionality can be found under [AsyncAPI Differences](../async_api_differences).

## AMQP Support

1. Consumers
   1. Timed retry
   2. Max retry
   3. Placing messages in an 'error queue' upon reaching max retry
2. Greylog integration
3. Integration with existing/legacy AMQP services
4. Worker hosting
   1. Fork/Exec standard ruby process hosting
   2. Adjustable worker counts
   3. Worker process identification and resource tracking

## HTTP Support

1. Transport layer security
   1. configuration support for acceptance of unofficial server certificates
   2. Basic Authentication/Digest Support in HTTP headers
   3. Signed Request/GitHub style digest authentication support
2. HTTP session sharing for secure connections

## Other Tasks

Connection resolution during the activation/initialization of channels and operations:
1. Should be either be refactored from or delegated to proxy classes in minimal instances, otherwise living in some sort of connection lookup operation in accordance with our clean code practices.
2. This would allow easier testing and diagnosis of connection lookup, as well as easier addition of logging information during the process.