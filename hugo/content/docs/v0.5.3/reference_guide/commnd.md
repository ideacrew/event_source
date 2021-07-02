---
title: Command
description: Mixin to build and publish an Event
---

Commands are an application's on-ramp to event-driven features. Mix `EventSource::Command` into any class to turn it into a Command and enable access to the DSL's Events.

The following example adds the mixin to an existing Operation class.

<!-- prettier_ignore_start -->

```ruby
# app/operations/organizations/create_general_organization.rb

class Organizations::GeneralOrganizationCreate
 include EventSource::Command
 include Logging
 send(:include, Dry::Monads[:result, :do])
 send(:include, Dry::Monads[:try])

 def call(params)
   values = yield validate(params)
   organization = yield create_general_organization(values)
   publish_event(organization)
   Success(organization)
 end

 ...
end
```

Command names use imperative form, for example: `Create`, `Update`, `Delete`. Where they already exist, Operations developed using [Dry::Transaction](https://dry-rb.org/gems/dry-transaction) mixin are likely candidates to extend as Commands.

Create events using the `event` keyword followed by a reference to its `event_key` - a stringified, dot-notation reference to an existing Event class. The system will raise a runtime error if an event matching the `event_key` isn't found.

For the following `publish_event` method, the Command will publish the event `organizations.general_organization_created`. Assigning a hash to the `attributes` option adds those key/value pairs to the event's message payload.

<!-- prettier_ignore_start -->

```ruby
def publish_event(organization)
  event =
    event 'organizations.general_organization_created',
          attributes: organization.to_h
  event.publish
  logger.info "Published event: #{event}"
end
```

<!-- prettier_ignore_end -->
