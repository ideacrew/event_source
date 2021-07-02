---
title: Event
description: Notifications about something that happens in the system
---

Events are signals about anything notable that happens in the system. For example, events can indicate that an enrollment period has begun, an eligibility determined, an application submitted and an enrollment effectuated. Event names use past tense form as a convention, for example: `Created`, `Updated`, `Deleted`.

Events are subclassed from the `EventSource::Event` class. An Event class must include a `publisher_path`. The `publisher_path` is a dot-notation, stringified class name that specifies the topic where event instances are published.

For example, the following event has a `publisher_path` referencing the `Organizations::OrganiztionPublisher` class. It also enumerates four `attribute_keys`: `:hbx_id, :legal_name, :fein, :entity_kind`.

```ruby
 # app/event_source/events/organizations/general_organization/created.rb

 class Organizations::GeneralOrganizationCreated < EventSource::Event
   publisher_path 'organizations.organization_publisher'
   attribute_keys :hbx_id, :legal_name, :fein, :entity_kind
   ...
 end
```

As shown in this example, an Event may optionally specify an Event payload's attribute keys by including `attribute_keys`. Note that this establishes a contract for attributes that must in an event's attribute payload. Each event must include a value for each the specified key. Missing key/value pairs will prevent publishing the event instance. Additional key/value pairs are ignored.

Events that don't specify `attribute_keys` do not validate and allow any passed key/value pairs as instance attributes.

Here's an example of an `Organizations::GeneralOrganizationCreated` instance:

<!-- prettier_ignore_start -->

```ruby
created_event = Organizations::GeneralOrganizationCreated.new
# => <Organizations::GeneralOrganizationCreated:0x00007fe642ff8748>

created_event.valid?
# => false

created_event.event_errors
# => ["missing required keys: [:hbx_id, :legal_name, :fein, :entity_kind]"]

created_event.attributes = {
  hbx_id: '12345',
  legal_name: 'ACME Corp',
  entity_kind: :c_corp,
  fein: '898784125',
}
# => {:hbx_id=>"12345", :legal_name=>"ACME Corp", :entity_kind=>:c_corp, :fein=>"898784125"}

created_event.valid?
# => true
```

<!-- prettier_ignore_end -->
