# frozen_string_literal: true
require 'event_source/logging'

RSpec.describe EventSource do
  let(:logger) { Logging.logger['SuperLogger'] }

  it 'should be able to read a log message' do
    binding.pry
    logger.debug 'foo bar'
    logger.warn 'just a little warning'

    @log_output.readline.should be == 'DEBUG SuperLogger: foo bar'
    @log_output.readline.should be == 'WARN  SuperLogger: just a little warning'
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
