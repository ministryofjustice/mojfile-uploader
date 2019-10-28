# frozen_string_literal: true
source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

ruby '2.5.7'

gem 'azure-storage-blob', '~> 1.1'
gem 'aws-sdk'
gem 'azure_env_secrets', github: 'ministryofjustice/azure_env_secrets', tag: 'v0.1.3'
gem 'logstash-logger'
gem 'nokogiri'
gem 'pry'
gem 'puma'
gem 'rake'
gem 'rest-client'
gem 'sanitize'
gem 'sentry-raven'
gem 'sinatra'

group :development, :test do
  gem 'mutant-rspec'
  gem 'pry-byebug'
  gem 'rspec'
end

group :test do
  gem 'brakeman'
  gem 'capybara'
  gem 'dotenv'
  gem 'fuubar'
  gem 'rack-test'
  gem 'rspec_junit_formatter', '~> 0.4.1'
  gem 'rubocop', require: false
  gem 'rubocop-rspec', require: false
  gem 'simplecov', require: false
  gem 'webmock'
end
