---
title: Naming Convention
---

EventSource uses a naming convention to associate Rails Publisher and Subscriber mixins and their resources with AsyncAPI definition counterparts. In some cases, underlying protocols impose constraints.  Here are the rules and conventions to follow.

### AsyncAPI Definitions

Rules and conventions for AsyncAPI definition resource names

1. Channel keys must be unique across the Enterprise
2. Channel keys and Publish Operation IDs typically share the same name
3. Channel keys and Subscribe Operation IDs typically share the Publish Operation ID with delimited 'on' string prepended
4. Operation IDs must be unique across the Enterprise

```yml
channels:
  organizations.organization_events:
    publish:
      operationId: organizations.organization_events

...

    subscribe:
      operationId: on_organizations.organization_events
```


### EventSource Publishers

Rules and conventions for EventSource::Publisher resource names

#### Mixin Declaration

1. A Publisher key that specifies the protocol, and
2. A Publisher value that matches the name of the AsyncAPI definition's Publish OperationID, and
3. That value may be dot-delimited (AMQP protocol) or slash-delimited (HTTP protocol)

```ruby
# app/event_source/publishers/organizations/organization_publisher.rb

class OrganizationPublisher
  include ::EventSource::Publisher[amqp: 'organizations.organization_events']
```

#### Event Declaration

Event names support namespacing, prefixing the EventSource Publisher value under the following conditions: 

1. Event names may match the EventSource::Publisher value (e.g. when HTTP service has a single resource), or
2. Event names may include the full name: EventSource::Publisher value concatendatd by the event name, or
3. Event names may specify the non-namespaced event name only

The following example is an instance of #3. The non-namespaced value `'organizations.organization_events` is declared.  The full, namespaced event name is: `organizations.organization_events.general_organization_created`

```ruby
class OrganizationPublisher
  include ::EventSource::Publisher[amqp: 'organizations.organization_events']

  register_event 'general_organization_created'
```

### EventSource Subscribers

Rules and conventions for EventSource::Subscriber resource names

#### Mixin Declaration

1. A Subscriber key that specifies the protocol, and
2. A Subscriber value that matches:
   1. Publisher value for the Publisher key of interest
   2. AsyncAPI definition's Channel Publish OperationID, and
3. That value may be dot-delimited (AMQP protocol) or slash-delimited (HTTP protocol)

```ruby
# app/event_source/subscribers/enroll/organizations/organization_subscriber.rb

class OrganizationSubscriber
  include EventSource::Logging
  include ::EventSource::Subscriber[amqp: 'organizations.organization_events']
```

#### Consumer Blocks

1. Subscribe block names are prefixed by 'on\_' and match the event name of interest

```ruby
subscribe(:on_polypress_general_organization_created) do |delivery_info, metadata, event|
...
end
```
