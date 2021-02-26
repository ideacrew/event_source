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
  context 'An Event class is initialized' do
    context "and it doesn't define a publisher_key" do
      it 'should raise an EventSource::PublisherKeyMissing error'
    end

    context 'and a Publisher is not found for the defined publisher_key' do
      it 'should raise an EventSource::PublisherNotDefined'
    end
  end

  context 'An Initialized Event class' do
    context 'and Attributes are defined' do
      it 'should do something useful'
    end

    context 'and an transform map is provided' do
    end
  end
end
