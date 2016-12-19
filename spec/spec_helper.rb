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

  config.before(:each) do
    # Taken from an S3 IAM example response at:
    # http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/iam-roles-for-amazon-ec2.html
    # Expiration adjusted to ensure it does not expire in the life of this probject.
    s3_access_response = {
      Code: "Success",
      LastUpdated: "2012-04-26T16:39:16Z",
      Type: "AWS-HMAC",
      AccessKeyId: "AKIAIOSFODNN7EXAMPLE",
      SecretAccessKey: "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY",
      Token: "token",
      Expiration: "2400-01-01T22:39:16Z"
    }

    stub_request(:get, /\/latest\/meta-data\/iam\/security-credentials\//).
      to_return(status: 200, body: s3_access_response.to_json)
  end

  config.around(:each) do |example|
    original_bucket = ENV['BUCKET_NAME']
    ENV['BUCKET_NAME'] = 'uploader-test-bucket'
    example.run
    ENV['BUCKET_NAME'] = original_bucket
  end
end
