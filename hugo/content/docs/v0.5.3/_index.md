---
title: EventSource
description: Usage and Configuration
---

EventSource simplifies Event-Driven Achitecture (EDA) design by adding helpers and interfaces that abstract away many of the underlying complexities associated with composing, publishing and subscribing to events - Event Sourcing Lite.

The gem uses and extends [AsyncApi](https://www.asyncapi.com/docs/specifications/2.0.0) to present a standards-based DSL for services to publish and subscribe to event messages. The DSL applies the Adapter development pattern to abstract away differences between underlying message exchange protocols.
