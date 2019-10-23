# Load ENV variables from the Azure Key Vault
require 'azure_env_secrets'
::AzureEnvSecrets.load

require 'raven'
require 'sinatra'
require_relative 'app'

Raven.configure do |config|
  config.ssl_verification = ENV['SENTRY_SSL_VERIFICATION'] == true
end

# Will use SENTRY_DSN environment variable if set
use Raven::Rack

run MojFile::Uploader
