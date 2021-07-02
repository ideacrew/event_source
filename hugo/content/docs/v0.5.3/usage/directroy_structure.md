---
title: Directory Structure
---

EventSource looks for Events, Publihsers and Subscribers under the `app/event_source` folder in respective subfolders. Commands may be found anywhere under the `app/` folder but are typically located under `app/operations`.

The following is an example folder tree for an EventSource-enabled project.

```ruby
app
  |- contracts
  | |- organizations
  | | |- organization_contract.rb
  |- entities
  | |- organizations
  | | |- organization.rb
  |- event_source
  | |- events
  | | |- organizations
  | | | |- address_updated.rb
  | | | |- general_organization_created.rb
  | | | |- general_organization_fein_corrected.rb
  | | | |- general_organization_fein_updated.rb
  | |- subscribers
  | | |- polypress
  | | | |- enroll_medicaid_notices.rb
  | | |- medicaid_gateway
  | | | |- eligiblity_determinations.rb
  | |- publishers
  | | |- organizations
  | | | | |- organization_publisher.rb
  |- operations
  | |- organizations
  | | |- correct_or_update_general_organization_fein.rb
  | | |- create_general_organization_fein.rb
  | | |- update_address.rb
```

This structure will result in dot-namespaced values like the following:

```ruby
"organizations.exempt_organization" # (entity)
"organizations.general_organization" # (entity)
"contracts.organizations.exempt_organization_contract" # (contract)
"contracts.organizations.general_organization_contract" # (contract)
"organizations.general_organization_model" # (model)
"organizations.exempt_organization_model" # (model)
"operations.organizations.create_general_organization" # (command / operation)
"events.organizations.general_organization_created" # (event)
"events.organizations.address_updated" # (event)
"publishers.organizations.organizations_publisher"(publisher)
"subscribers.polypress.enroll_medicaid_notices_subscriber" (subscriber)
"subscribers.medicaid_gateway.eligiblity_determinations_subscriber"(subscriber)
```

And Routing Keys like the following:

```ruby
medicaid_gateway_channal_item_name: magi_medicaid.mitc.eligibilities.determined_mixed_eligible
medicaid_gateway_publish_operation_id: magi_medicaid.mitc.eligibilities.determined_mixed_eligible
medicaid_gateway_publish_operation_id: magi_medicaid.mitc.eligibilities.determined_mixed_eligible
medicaid_gateway_exchange name (bindings): magi_medicaid.mitc.eligibilities
medicaid_gateway_routing key (bindings): magi_medicaid.mitc.eligibilities.determined_mixed_eligible
polypress_subscriber: on_polypress.magi_medicaid.mitc.eligibilities

```
