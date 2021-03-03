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
      expect(event_class.new.attribute_keys.map(&:key)).to eq %i[hbx_id fein entity_kind]
    end

    context 'and one or more attribute values are missing' do
      let(:hbx_id) { '12345' }

      it '#valid? should return false' do
        expect(event_class.new.valid?).to be_falsey
      end
    end

    context 'and all attribute values are present' do
      it '#valid? should return true' do
        event = event_class.new
        # event[:fein]
        event[:fein] = 'test'
        expect(event_class.new.valid?).to be_truthy
      end
    end

    context 'and all attribute values are present along with additional attributes' do
      it '#valid? should return true' do
        expect(event_class.new.valid?).to be_truthy
      end

      it 'should ignore extra attributes' do
        expect(event_class.new.valid?).to be_truthy
      end
    end
  end

  context 'An initialized Event class with no attribute_keys' do

    let(:event_class) do
      class MyEvent < EventSource::Event
        publisher_key 'parties.organization_publisher'
      end
      MyEvent
    end

    context 'with attributes passed' do 
      it '#valid? should return true' do
        expect(event_class.new.valid?).to be_truthy
      end

      it 'payload should include all attributes passed' do
        expect(event_class.new.attribute_keys.map(&:key)).to eq %i[hbx_id fein entity_kind]
      end
    end

    context 'with no attributes passed' do
      let(:hbx_id) { '12345' }

      it '#valid? should return true' do
        expect(event_class.new.valid?).to be_truthy
      end

      it 'payload should be an empty hash' do
      end
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
