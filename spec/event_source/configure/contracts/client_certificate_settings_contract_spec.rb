# frozen_string_literal: true

require 'spec_helper'

RSpec.describe EventSource::Configure::Contracts::ClientCertificateSettingsContract,
               "given nothing" do

  let(:parameters) { {} }

  subject { described_class.new.call(parameters) }

  it "is invalid" do
    expect(subject.success?).to be_falsey
  end
end

RSpec.describe EventSource::Configure::Contracts::ClientCertificateSettingsContract,
               "given:
    - a client certificate with invalid path
    - a client key with invalid path" do

  let(:parameters) do
    {
      client_certificate: "bloogle",
      client_key: "blargle"
    }
  end

  subject { described_class.new.call(parameters) }

  it "is invalid" do
    expect(subject.success?).to be_falsey
  end

  it "has path errors on the client certificate" do
    errors = subject.errors.to_h
    expect(errors.key?(:client_certificate)).to be_truthy
    expect(errors[:client_certificate].first[:text]).to eq "has an invalid path"
  end

  it "has path errors on the client key" do
    errors = subject.errors.to_h
    expect(errors.key?(:client_key)).to be_truthy
    expect(errors[:client_key].first[:text]).to eq "has an invalid path"
  end
end

RSpec.describe EventSource::Configure::Contracts::ClientCertificateSettingsContract,
               "given:
    - a client certificate with a valid
    - a client key a valid path, needing a password
    - no password" do

  let(:certificate_location) do
    File.expand_path(
      File.join(
        File.dirname(__FILE__),
        "cert_needs_pass.pem"
      )
    )
  end

  let(:key_location) do
    File.expand_path(
      File.join(
        File.dirname(__FILE__),
        "key_needs_pass.key"
      )
    )
  end

  let(:parameters) do
    {
      client_certificate: certificate_location,
      client_key: key_location
    }
  end

  subject { described_class.new.call(parameters) }

  it "is invalid" do
    expect(subject.success?).to be_falsey
  end
end

RSpec.describe EventSource::Configure::Contracts::ClientCertificateSettingsContract,
               "given:
    - a client certificate with a valid
    - a client key a valid path, needing a password
    - an incorrect password" do

  let(:certificate_location) do
    File.expand_path(
      File.join(
        File.dirname(__FILE__),
        "cert_needs_pass.pem"
      )
    )
  end

  let(:key_location) do
    File.expand_path(
      File.join(
        File.dirname(__FILE__),
        "key_needs_pass.key"
      )
    )
  end

  let(:parameters) do
    {
      client_certificate: certificate_location,
      client_key: key_location,
      client_key_password: "some garbage"
    }
  end

  subject { described_class.new.call(parameters) }

  it "is invalid" do
    expect(subject.success?).to be_falsey
  end
end

RSpec.describe EventSource::Configure::Contracts::ClientCertificateSettingsContract,
               "given:
    - a client certificate with a valid
    - a client key a valid path, needing a password
    - a correct password" do

  let(:certificate_location) do
    File.expand_path(
      File.join(
        File.dirname(__FILE__),
        "cert_needs_pass.pem"
      )
    )
  end

  let(:key_location) do
    File.expand_path(
      File.join(
        File.dirname(__FILE__),
        "key_needs_pass.key"
      )
    )
  end

  let(:parameters) do
    {
      client_certificate: certificate_location,
      client_key: key_location,
      client_key_password: "testpasswd"
    }
  end

  subject { described_class.new.call(parameters) }

  it "is valid" do
    expect(subject.success?).to be_truthy
  end
end

RSpec.describe EventSource::Configure::Contracts::ClientCertificateSettingsContract,
               "given:
    - a client certificate with a valid
    - a client key a valid path, no password
    - no password" do

  let(:certificate_location) do
    File.expand_path(
      File.join(
        File.dirname(__FILE__),
        "cert_no_pass.pem"
      )
    )
  end

  let(:key_location) do
    File.expand_path(
      File.join(
        File.dirname(__FILE__),
        "key_no_pass.key"
      )
    )
  end

  let(:parameters) do
    {
      client_certificate: certificate_location,
      client_key: key_location
    }
  end

  subject { described_class.new.call(parameters) }

  it "is valid" do
    expect(subject.success?).to be_truthy
  end
end