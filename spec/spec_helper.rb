ENV['RACK_ENV'] = 'test'
require 'dotenv'
Dotenv.load

require_relative '../app'
require 'rspec'
require 'rack/test'
require 'webmock/rspec'
require 'pry'

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

  ENV['AZURE_STORAGE_ACCOUNT'] = 'dummy-account'
  ENV['AZURE_STORAGE_ACCESS_KEY'] = 'ZHVtbXktYWNjZXNzLWtleSBrZXk='
  ENV['CONTAINER_NAME'] = 'dummy-container'
end
