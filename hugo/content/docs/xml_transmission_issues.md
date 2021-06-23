---
title: XML Transmission Issues
description: Issues that currently prevent the usage of XML as an encoding medium and need to be corrected.

---

There are several locations in the code where it is currently assumed we will be sending JSON.  These need to be either corrected or configurable in order to have working XML/SOAP interaction.

1. FaradayConnectionProxy
   1. The Faraday adapter and it's associated middleware is chosen before the Operations are even inspected - meaning it is currently unaware of the possible mime-type differences between endpoints.  Middleware should be chosen once the mimetype and encoding of an endpoint can be known.
   2. It assumes JSON for all things as the default middleware.
2. FaradayRequestProxy
   1. Currently assumes that the submitted payload will be JSON and always attempts to parse it for a Correlation ID.
   2. Sends invalid and non-normative HTTP headers.  Custom http headers should be indicated with "X-", as in "X-CorrelationId".
3. EventSource::PublishOperation, assumes all payloads are to be sent as JSON, and performs serialization of the message to JSON.