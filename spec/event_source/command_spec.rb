require 'spec_helper'

RSpec.describe EventSource::Command do
  context '.event' do

  	it 'should register event' do
  	  Organizations::Create.new.call({fein: '546232323'})
  	end
  end
end