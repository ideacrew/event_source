# frozen_string_literal: true

require 'event_source/logging'

class LogService
  include EventSource::Logging
end

RSpec.describe EventSource::Logging do
  # let(:logger) { described_class.logger['EventSource::Logging'] }
  let(:logger) { LogService.new.logger }

  let(:executable) { proc { logger.info "Hello world!!"} }

  it 'should be able to read a log message' do

    #  service = ::LogService.new
    #  service.instance_exec(&executable)

    logger.debug 'foo bar'
    logger.warn 'just a little warning'

    expect(@log_output.readline.strip).to eq 'DEBUG  EventSource : foo bar'
    expect(@log_output.readline.strip).to eq 'WARN  EventSource : just a little warning'
  end

  # let(:klass) do
  #   class LogKlass
  #     include EventSource::Logging
  #     def log_message
  #       Logging.logger.info 'class initialized'
  #     end
  #   end
  # end

  # context 'When a message is sent to the logger' do
  #   it 'should create a log entry in expected format' do
  #     log_klass = klass.new
  #     binding.pry
  #     expect(log_klass.log_message).to be_truthy
  #   end
  # end
end
