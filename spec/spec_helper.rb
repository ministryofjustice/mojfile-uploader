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

  config.around(:each) do |example|
    original_bucket = ENV['BUCKET_NAME']
    original_key = ENV['ACCESS_KEY_ID']
    original_secret= ENV['SECRET_ACCESS_KEY']
    ENV['BUCKET_NAME'] = 'uploader-test-bucket'
    ENV['ACCESS_KEY_ID'] = 'dummy key'
    ENV['SECRET_ACCESS_KEY'] = 'dummy secret'
    example.run
    ENV['BUCKET_NAME'] = original_bucket
    ENV['ACCESS_KEY_ID'] = original_key
    ENV['SECRET_ACCESS_KEY'] = original_secret
  end
end
