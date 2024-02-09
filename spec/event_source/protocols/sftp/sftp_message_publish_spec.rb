# frozen_string_literal: true

require 'rails_helper'

class SftpProtocolExamplePublisher < ::EventSource::Publisher
  include ::EventSource::Publisher[sftp: 'some.file']

  register_event "upload_to_cms"
end

class UploadToCms < ::EventSource::Event
  publisher_path("sftp_protocol_example_publisher")
end

class SftpProtocolExamplePublishingContext
  include ::EventSource::Command
end

RSpec.describe EventSource::Protocols::Sftp, "with a publisher definition loaded" do
  let(:async_api_file) do
    Pathname.pwd.join(
      'spec',
      'support',
      'asyncapi',
      'sftp_example_publish.yml'
    )
  end
  let(:config) do
    EventSource::AsyncApi::Operations::AsyncApiConf::LoadPath
      .new
      .call(path: async_api_file)
      .value!
  end

  let(:test_file_upload_path) do
    File.expand_path(
      File.join(
        File.dirname(__FILE__),
        "..",
        "..",
        "..",
        "mock_services",
        "sftp_server_root",
        "some_Crazy_GeneratedFilename.zip"
      )
    )
  end

  let(:server_run_path) do
    File.expand_path(
      File.join(
        File.dirname(__FILE__),
        "..",
        "..",
        "..",
        ".."
      )
    )
  end

  before(:each) do
    FileUtils.rm_f(test_file_upload_path)
    @sftp_server_pid = spawn(
      "bundle exec ruby spec/mock_services/sftp_server.rb",
      {
        :chdir => server_run_path
      }
    )
    sleep(1)
    EventSource::ConnectionManager.instance.drop_connections_for(:http)
    EventSource::ConnectionManager.instance.drop_connections_for(:amqp)
    EventSource::ConnectionManager.instance.drop_connections_for(:sftp)
    EventSource.create_connections
    EventSource.config.async_api_schemas = [config]
    EventSource.config.load_async_api_resources
  end

  after(:each) do
    Process.kill("INT", @sftp_server_pid)
  end

  it "can publish a message" do
    pub_context = SftpProtocolExamplePublishingContext.new
    event = pub_context.event(
      "upload_to_cms", 
      attributes: {
        data: "SOME RAW DATA",
        filename: "some_Crazy_GeneratedFilename.zip"
      }
    )
    event.value!.publish
    expect(File.exist?(test_file_upload_path)).to be_truthy
  end
end