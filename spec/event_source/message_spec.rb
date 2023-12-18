# frozen_string_literal: true

module EventSource
  class MyValidEvent < EventSource::Event
    publisher_path 'parties.organization_publisher'
  end

  class MyEvent < EventSource::Event
    publisher_path 'parties.organization_publisher'
    attribute_keys :hbx_id, :fein, :entity_kind
  end

  class MyEventTwo < EventSource::Event
    publisher_path 'parties.organization_publisher'
  end

  class MyEventThree < EventSource::Event
    publisher_path 'parties.organization_publisher'
    attribute_keys :hbx_id, :entity_kind, :fein, :legal_name
  end
end

RSpec.describe EventSource::Event do
  context 'A new Event class' do
  
    context 'and the required publisher_path provided is valid' do
      let(:valid_event_class) { EventSource::MyValidEvent }

      subject { valid_event_class.new }

      it 'should have an event_key' do
        expect(subject.name).to eq 'event_source.my_valid_event'
      end
    end

    context 'with a defined contract_class' do
      context "and the contract_class isn't defined" do
        it 'should raise an EventSource::Errors::ContractNotDefined'
      end
    end
  end

  context 'An initialized Event class with defined attribute_keys' do
    let(:event_class) { EventSource::MyEvent }

    it 'keys should be initialized for each attribute' do
      expect(event_class.new.attribute_keys).to eq %i[hbx_id fein entity_kind]
    end

    subject { event_class.new(attributes: attributes) }


    context 'and all attribute values are present' do
      let(:attributes) do
        { hbx_id: '553234', entity_kind: 'c_corp', fein: '546232323' }
      end

      it '#valid? should return true' do
        expect(subject.valid?).to be_truthy
      end
    end
  end

  context 'An initialized Event class with no attribute_keys' do
    let(:event_class) { EventSource::MyEventTwo }

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

      it 'attributes should be an empty hash' do
        expect(subject.payload).to be_empty
      end
    end

    context 'and with attributes passed' do
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
        expect(subject.payload).to eq attributes
      end
    end
  end

  context 'An initialized Event class with attribute_keys' do
    let(:event_class) { EventSource::MyEventThree }

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
        expect(subject.valid?).to be_truthy
      end
      it 'should have all attributes' do
        expect(subject.payload).to eq attributes
      end
    end

    context 'with attribute getter' do
      let(:attributes) { { hbx_id: '553234', fein: '546232323' } }

      subject { event_class.new(attributes: attributes) }

      context 'when attribute name is passed' do
        it 'should return the value' do
          expect(subject[:fein]).to eq attributes[:fein]
          expect(subject[:hbx_id]).to eq attributes[:hbx_id]
        end
      end
    end
  end
end
