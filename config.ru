# Load ENV variables from the Azure Key Vault
require 'azure_env_secrets'
::AzureEnvSecrets.load

require 'raven'
require 'sinatra'
require_relative 'app'

# Will use SENTRY_DSN environment variable if set
use Raven::Rack

run MojFile::Uploader
