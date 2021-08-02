---
title: Protocols
description: Protocols supported by EventSource
---

When developing or updating any system feature you will decide which event messages (or signals) that feature will consume and publish. Events and their associated messages determine a program's flow and can trigger reactors that spawn new processes and activities.

Another consideration is which message protocol to use for transmitting event messages. EventSoure supports multiple protocols between and each has their advantages and drawbacks. Frequently which protocol you will use is already deciddetermineded. For example you may need to access an outside service that exposes an API using HTTP protocol. Or you may add a feature that taps into an existing AMQP message fabric.
