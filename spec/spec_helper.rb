require_relative '../app'
require 'rspec'
require 'rack/test'
require 'webmock/rspec'

ENV['RACK_ENV'] = 'test'

def app
  MojFile::Uploader
end

WebMock.disable_net_connect!(allow_localhost: true)

RSpec.configure do |config|
  config.include Rack::Test::Methods

  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups

  #config.before(:each) do
    #stub_request(:get, /\/latest\/meta-data\/iam\/security-credentials\//).
      #to_return(:status => 200, :body => "", :headers => {})
  #end

  config.around(:each) do |example|
    original_bucket = ENV['BUCKET_NAME']
    ENV['BUCKET_NAME'] = 'uploader-test-bucket'
    example.run
    ENV['BUCKET_NAME'] = original_bucket
  end
end
