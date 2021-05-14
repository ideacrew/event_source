# frozen_string_literal: true

require 'spec_helper'

RSpec.describe EventSource::Operations::Codec64 do
  context 'Given an invalid file' do
    let(:transform) { :encode }
    let(:source_filename) { 'phoney_phoney_phoney.file' }

    it 'should raise an error' do
      expect {
        subject.call(transform: transform, source_filename: source_filename)
      }.to raise_error EventSource::Error::FileAccessError
    end
  end

  context 'Given a valid binary file' do
    let(:transform) { :encode }
    let(:source_filename) { './spec/support/Simple Event Flow (no CQRS).png' }
    let(:file_content_encoded_size) { 536_939 }
    let(:file_content_encoded_start_chars) do
      'iVBORw0KGgoAAAANSUhEUgAACcQAAAeMCAYAAACdRw'
    end

    it 'the decoded contents should match the source file content' do
      result =
        subject.call(transform: transform, source_filename: source_filename)

      expect(result.success?).to be_truthy
      expect((result.value!).size).to eq file_content_encoded_size
      expect(result.value!).to start_with file_content_encoded_start_chars
    end
  end

  context 'Given a binary string' do
    let(:binary_string) { "\007\007\002\abdce" }
    let(:encoded_string) { 'BwcCB2JkY2U=' }

    context 'and the transform operation is set to encode'
    let(:transform) { :encode }

    it 'should encode the value' do
      expect(
        subject.call(transform: transform, source_value: binary_string).value!
      ).to eq encoded_string
    end

    context 'and the tranform operation is set to :decode' do
      let(:transform) { :decode }

      it 'should decode the value' do
        expect(
          subject.call(transform: transform, source_value: encoded_string)
            .value!
        ).to eq binary_string
      end
    end

    context 'and the tranform operation value is missing or not equal to :decode' do
      let(:phoney_transform) { :phoney }

      it 'should encode the value' do
        expect(
          subject.call(source_value: binary_string).value!
        ).to eq encoded_string
      end
      it 'should encode the value' do
        expect(
          subject.call(transform: phoney_transform, source_value: binary_string)
            .value!
        ).to eq encoded_string
      end
    end
  end
end
