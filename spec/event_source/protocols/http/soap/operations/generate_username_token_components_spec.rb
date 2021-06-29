# frozen_string_literal: true

require "spec_helper"

RSpec.describe EventSource::Protocols::Http::Soap::Operations::GenerateUsernameTokenComponents,
               "given a SecurityHeaderConfiguration:
  - without a timestamp required
  - with no digest encoding provided
  " do

  let(:security_header_configuration) do
    ::EventSource::Protocols::Http::Soap::SecurityHeaderConfiguration.new(
      {
        user_name: "a username",
        password: "a password"
      }
    )
  end

  before :each do
    allow(SecureRandom).to receive(:random_bytes).with(16).and_return("1234567890123456")
    allow(Time).to receive(:now).and_return(Time.new(2021, 1, 13, 20, 4, 0, "+00:00"))
  end

  subject do
    described_class.new.call(security_header_configuration)
  end

  it "encodes the username" do
    expect(subject.value!.username).to eq "a username"
  end

  it "encodes a digest" do
    expect(subject.value!.password_digest).to eq "gezxLszKnZi//gE5Ewnj6vq/T4E="
  end

  it "encodes a nonce" do
    expect(subject.value!.encoded_nonce).to eq "MTIzNDU2Nzg5MDEyMzQ1Ng=="
  end

  it "encodes a token created value" do
    expect(subject.value!.created_value).to eq "2021-01-13T20:04:00.000Z"
  end

  it "generates token values without a timestamp" do
    expect(subject.value!.security_timestamp_value).to eq nil
  end

  it "encodes using digest by default" do
    expect(subject.value!.digest_encoding).to eq EventSource::Protocols::Http::Soap::USERTOKEN_DIGEST_VALUES[:digest]
  end
end

RSpec.describe EventSource::Protocols::Http::Soap::Operations::GenerateUsernameTokenComponents,
               "given a SecurityHeaderConfiguration:
  - with a timestamp required
  - with plain digest encoding provided
  " do

  let(:security_header_configuration) do
    ::EventSource::Protocols::Http::Soap::SecurityHeaderConfiguration.new(
      {
        user_name: "a username",
        password: "a password",
        password_encoding: :plain,
        use_timestamp: true
      }
    )
  end

  before :each do
    allow(SecureRandom).to receive(:random_bytes).with(16).and_return("1234567890123456")
    allow(Time).to receive(:now).and_return(Time.new(2021, 1, 13, 20, 4, 0, "+00:00"))
  end

  subject do
    described_class.new.call(security_header_configuration)
  end

  it "encodes the username" do
    expect(subject.value!.username).to eq "a username"
  end

  it "encodes the password as the digest" do
    expect(subject.value!.password_digest).to eq "a password"
  end

  it "encodes a nonce" do
    expect(subject.value!.encoded_nonce).to eq "MTIzNDU2Nzg5MDEyMzQ1Ng=="
  end

  it "encodes a token created value" do
    expect(subject.value!.created_value).to eq "2021-01-13T20:04:00.000Z"
  end

  it "generates token values without a timestamp" do
    timestamp_value = subject.value!.security_timestamp_value
    expect(timestamp_value).not_to eq nil
    expect(timestamp_value.created).to eq "2021-01-13T20:04:00.000Z"
    expect(timestamp_value.expires).to eq "2021-01-13T20:05:00.000Z"
  end

  it "encodes using plain" do
    expect(subject.value!.digest_encoding).to eq EventSource::Protocols::Http::Soap::USERTOKEN_DIGEST_VALUES[:plain]
  end
end