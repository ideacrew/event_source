require 'webmock/rspec'
WebMock.disable_net_connect!(allow_localhost: true)

RSpec.configure do |config|
  config.before(:each) do
    stub_request(:any, /api.github.com/).to_rack(FakeGitHub)
    # stub_request(:get, /api.github.com/)
    #   .with(headers: { 'Accept' => '*/*', 'User-Agent' => 'Ruby' })
    #   .to_return(status: 200, body: 'stubbed response', headers: {})
  end
end
