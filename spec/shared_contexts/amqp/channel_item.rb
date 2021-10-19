# frozen_string_literal: true
RSpec.shared_context 'channel bindings', shared_context: :metadata do
  let(:channel_id) { 'crm_contact_created' }

  let(:channel_bindings) do
    {
      amqp: {
        is: :routing_key,
        exchange: {
          name: 'spec.crm_contact_created',
          type: 'topic',
          content_type: 'application/json',
          durable: true,
          auto_delete: false,
          vhost: 'event_source'
        },
        queue: {
          name: 'on_spec.spec.crm_contact_created',
          durable: true,
          exclusive: false,
          auto_delete: false,
          vhost: 'event_source'
        },
        binding_version: '0.2.0'
      }
    }
  end
end

RSpec.shared_context 'channel item with publish operation',
                     shared_context: :metadata do
  include_context 'channel bindings'

  let(:publish_operation) do
    {
      operationId: 'on_crm_sugarcrm_contacts_contact_created',
      summary: 'SugarCRM Contact Created',
      message: {
        '$ref':
          '#/components/messages/crm_sugar_crm_contacts_contact_created_event',
        payload: {
          'hello' => 'world!!'
        }
      },
      bindings: {
        amqp: {
          app_id: 'spec',
          type: 'spec.crm_contact_created',
          routing_key:
            'spec.crm_contact_created.crm_sugarcrm_contacts_contact_created',
          deliveryMode: 2,
          mandatory: true,
          timestamp: true,
          content_type: 'application/json',
          bindingVersion: '0.2.0'
        }
      }
    }
  end

  let(:async_api_publish_channel_item) do
    {
      id: 'publish channel id',
      publish: publish_operation,
      bindings: channel_bindings
    }
  end

  let(:publish_channel_struct) do
    EventSource::AsyncApi::ChannelItem.new(async_api_publish_channel_item)
  end
end

RSpec.shared_context 'channel item with subscribe operation',
                     shared_context: :metadata do
  include_context 'channel bindings'

  let(:subscribe_operation) do
    {
      operationId: 'crm_sugarcrm_contacts_contact_created',
      summary: 'SugarCRM Contact Created',
      bindings: {
        amqp: {
          ack: true,
          exclusive: false,
          routing_key:
            'spec.crm_contact_created.crm_sugarcrm_contacts_contact_created',
          prefetch: 1,
          block: false,
          bindingVersion: '0.2.0'
        }
      }
    }
  end

  let(:async_api_subscribe_channel_item) do
    {
      id: 'subscribe channel id',
      subscribe: subscribe_operation,
      bindings: channel_bindings
    }
  end

  let(:subscribe_channel_struct) do
    EventSource::AsyncApi::ChannelItem.new(async_api_subscribe_channel_item)
  end
end
