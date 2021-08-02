# frozen_string_literal: true

require "spec_helper"

RSpec.describe EventSource::Protocols::Http::Soap::Operations::EncodeSoapPayload,
               "given a UsernameTokenValues and a body" do

  let(:username_token_values) do
    ::EventSource::Protocols::Http::Soap::UsernameTokenValues.new(
      {
        username: "a username",
        digest_encoding: "an encoding",
        encoded_nonce: "a nonce",
        password_digest: "a password digest",
        created_value: "a created value"
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
        username_token_values: username_token_values
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

  it "encodes the password in the header" do
    xml = Nokogiri::XML(subject.value!)
    username_token_node = xml.at_xpath(
      "//soap:Header/wsse:Security/wsse:UsernameToken/wsse:Password",
      EventSource::Protocols::Http::Soap::XMLNS
    )
    expect(username_token_node.text).to eq "a password digest"
  end

  it "encodes the nonce in the header" do
    xml = Nokogiri::XML(subject.value!)
    username_token_node = xml.at_xpath(
      "//soap:Header/wsse:Security/wsse:UsernameToken/wsse:Nonce",
      EventSource::Protocols::Http::Soap::XMLNS
    )
    expect(username_token_node.text).to eq "a nonce"
  end

  it "encodes the created in the header" do
    xml = Nokogiri::XML(subject.value!)
    username_token_node = xml.at_xpath(
      "//soap:Header/wsse:Security/wsse:UsernameToken/wsu:Created",
      EventSource::Protocols::Http::Soap::XMLNS
    )
    expect(username_token_node.text).to eq "a created value"
  end

  it "encodes digest encoding type in the header" do
    xml = Nokogiri::XML(subject.value!)
    username_token_node = xml.at_xpath(
      "//soap:Header/wsse:Security/wsse:UsernameToken/wsse:Password",
      EventSource::Protocols::Http::Soap::XMLNS
    )
    expect(username_token_node.attr("Type")).to eq "an encoding"
  end
end