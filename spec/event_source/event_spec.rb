# require 'spec_helper'

# 0. EventSource Gem supports domain model entities
# 1. Command
# 1.1 We will use Operations as ES Commands by doing: include EventSource::Events
# 1.2 An operation can have 1 or more Events
# 1.3 EventSource::Events builds events and fires event upon success of command
# 2. Event
# 2.1 Events are predefined and include attributes and validation using Dry Hash Schema & Dry Validation
# 3. Dispatcher
# 3.1 Use RuleSet and ListenerSet to register observers and distribute events
# 4. EventStream
# 4.1 Future: v0.3.0 will not include persistence

RSpec.describe EventSource::Event do
  context 'A new Event class' do
    context "and a publisher_key isn't defined" do
      let(:empty_event_class) do
        class MyEmptyEvent < EventSource::Event
          attribute_keys :hbx_id
        end
        MyEmptyEvent
      end
      let(:hbx_id) { '12345' }

      it 'should raise an EventSource::PublisherKeyMissing error' do
        expect {
          empty_event_class.new({ hbx_id: hbx_id })
        }.to raise_error EventSource::Error::PublisherKeyMissing
      end
    end

    context 'with a passed PublisherKey override' do
      it 'should use the override PublisherKey rather than default PublisherKey'

      context 'and a Publisher is not found for the override PublisherKey' do
        it 'should raise an EventSource::PublisherNotFound'
      end
    end

    context 'and a Publisher class is not found for the defined publisher_key' do
      it 'should raise an EventSource::PublisherNotFound'
    end

    context 'with a valid publisher_key' do
    end

    context 'with a defined contract_class' do
      context "and the contract_class isn't defined" do
        it 'should raise an EventSource::ContractNotDefined'
      end
    end
  end

  context 'An initialized Event class with defined attribute_keys' do
    let(:event_class) do
      class MyEvent < EventSource::Event
        publisher_key 'parties.organization_publisher'
        attribute_keys :hbx_id, :fein, :entity_kind
      end
      MyEvent
    end

    it 'keys should be initialized for each attribute' do
      expect(event_class.new.attribute_keys).to eq %i[hbx_id fein entity_kind]
    end

    subject { event_class.new(attributes: attributes) }

    context 'and one or more attribute values are missing' do
      let(:attributes) { { hbx_id: '451231' } }

      it '#valid? should return false' do
        expect(subject.valid?).to be_falsey
      end
    end

    context 'and all attribute values are present' do
      let(:attributes) do
        { hbx_id: '553234', entity_kind: 'c_corp', fein: '546232323' }
      end

      it '#valid? should return true' do
        expect(subject.valid?).to be_truthy
      end
    end

    context 'and all attribute values are present along with additional attributes' do
      let(:attributes) do
        {
          hbx_id: '553234',
          entity_kind: 'c_corp',
          fein: '546232323',
          legal_name: 'Test Corp LLC'
        }
      end

      it '#valid? should return true' do
        expect(subject.valid?).to be_truthy
      end

      it 'should ignore extra attributes' do
        extra_keys = attributes.keys - subject.attribute_keys

        extra_keys.each do |key|
          expect(subject.attributes.key?(key)).to be_falsey
        end
      end
    end
  end

  context 'An initialized Event class with no attribute_keys' do
    let(:event_class) do
      class MyEventTwo < EventSource::Event
        publisher_key 'parties.organization_publisher'
      end
      MyEventTwo
    end

    subject { event_class.new }
    it 'attribute_keys should be empty' do
      expect(subject.attribute_keys).to be_empty
    end

    context 'with no attributes passed' do
      it '#event_errors should be empty' do
        expect(subject.event_errors).to be_empty
      end

      it '#valid? should return true' do
        expect(subject.valid?).to be_truthy
      end

      it 'payload should be an empty hash' do
        expect(subject.attributes).to be_empty
      end
    end

    context 'with attributes passed' do
      let(:attributes) do
        {
          hbx_id: '553234',
          entity_kind: 'c_corp',
          fein: '546232323',
          legal_name: 'Test Corp LLC'
        }
      end

      subject { event_class.new(attributes: attributes) }

      it '#event_errors should be empty' do
        expect(subject.event_errors).to be_empty
      end
      it '#valid? should return true' do
        expect(subject.valid?).to be_truthy
      end
      it 'should have all attributes' do
        expect(subject.attributes).to eq attributes
      end

      it 'payload should include the attributes' do
        expect(subject.payload[:attributes]).to eq attributes
      end
    end
  end

  context 'An initialized Event class with attribute_keys' do
    let(:event_class) do
      class MyEventThree < EventSource::Event
        publisher_key 'parties.organization_publisher'
        attribute_keys :hbx_id, :entity_kind, :fein, :legal_name
      end
      MyEventThree
    end

    context 'with attributes passed' do
      let(:attributes) do
        {
          hbx_id: '553234',
          entity_kind: 'c_corp',
          fein: '546232323',
          legal_name: 'Test Corp LLC'
        }
      end

      subject { event_class.new(attributes: attributes) }

      it 'attribute_keys should be present' do
        expect(subject.attribute_keys).to eq %i[
             hbx_id
             entity_kind
             fein
             legal_name
           ]
      end
      it '#event_errors should be empty' do
        expect(subject.event_errors).to be_empty
      end
      it '#valid? should return true' do
        expect(subject.valid?).to be_true
      end
      it 'should have all attributes' do
        expect(subject.attributes).to eq attributes
      end

      it 'payload should include the attributes' do
        expect(subject.payload[:attributes]).to eq attributes
      end
    end

    context 'with no attributes passed' do
      it '#valid? should be false'
      it '#event_errors should list missing attributes'
    end

    context 'with at least one missing attribute' do
      it '#valid? should be false'
      it '#event_errors should list missing attributes'
    end
  end
end

# let(:attributes) do
#   {
#     old_state: {
#       hbx_id: '553234',
#       legal_name: 'Test Organization',
#       entity_kind: 'c_corp',
#       fein: '546232323'
#     },
#     new_state: {
#       hbx_id: '553234',
#       legal_name: 'Test Organization',
#       entity_kind: 'c_corp',
#       fein: '546232320'
#     }
#   }
# end

# let(:metadata) do
#   {
#     command_name: 'parties.organziation.correct_or_update_fein',
#     change_reason: 'corrected'
#   }
# end

# event 'parties.organization.fein_corrected', attributes: attributes

# event = event 'parties.organization.fein_corrected'
# event.attributes =  attributes

# event = event 'parties.organization.fein_corrected'
# event.fein = fein
# event.hbx_id = hbx_id

# event.valid?
# event.publish
