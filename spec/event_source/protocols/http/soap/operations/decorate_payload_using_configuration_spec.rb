# frozen_string_literal: true

require "spec_helper"

RSpec.describe EventSource::Protocols::Http::Soap::Operations::DecoratePayloadUsingConfiguration,
               "given a SecurityHeaderConfiguration and a body" do

  let(:security_settings) do
    ::EventSource::Protocols::Http::Soap::SecurityHeaderConfiguration.new(
      {
        username: "a username",
        password: "a password"
      }
    )
  end

  let(:body) do
    <<-XMLCODE
      <rootElement xmlns="urn:whatever">
      </rootElement>
    XMLCODE
  end

  subject do
    described_class.new.call(
      {
        body: body,
        security_settings: security_settings
      }
    )
  end

  it "encodes the body" do
    xml = Nokogiri::XML(subject.value!)
    soap_body_node = xml.at_xpath("//soap:Body", EventSource::Protocols::Http::Soap::XMLNS)
    body = soap_body_node.children.detect { |node| !node.text? }
    expect(body.canonicalize).to eq(
      "<rootElement xmlns=\"urn:whatever\" xmlns:soap=\"http://www.w3.org/2003/05/soap-envelope\">\n      </rootElement>"
    )
  end

  it "encodes the username in the header" do
    xml = Nokogiri::XML(subject.value!)
    username_token_node = xml.at_xpath(
      "//soap:Header/wsse:Security/wsse:UsernameToken/wsse:Username",
      EventSource::Protocols::Http::Soap::XMLNS
    )
    expect(username_token_node.text).to eq "a username"
  end

  it "encodes digest encoding type in the header" do
    xml = Nokogiri::XML(subject.value!)
    username_token_node = xml.at_xpath(
      "//soap:Header/wsse:Security/wsse:UsernameToken/wsse:Password",
      EventSource::Protocols::Http::Soap::XMLNS
    )
    expect(username_token_node.attr("Type")).to eq(
      "http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-username-token-profile-1.0#PasswordDigest"
    )
  end
end