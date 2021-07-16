# frozen_string_literal: true

# Load ENV variables from the Azure Key Vault
require 'azure_env_secrets'
::AzureEnvSecrets.load

require 'application_insights'
require 'sentry-ruby'
require 'sinatra'
require_relative 'app'

Sentry.init do |config|
  config.dsn = ENV['SENTRY_DSN']
  config.breadcrumbs_logger = [:sentry_logger, :http_logger]

  config.traces_sample_rate = 0.5
  # config.transport.ssl_verification = ENV['SENTRY_SSL_VERIFICATION'] == true
  config.transport.ssl_verification = true
end

use ApplicationInsights::Rack::TrackRequest, ENV['AZURE_APP_INSIGHTS_INSTRUMENTATION_KEY']

use Sentry::Rack::CaptureExceptions

run MojFile::Uploader
