# frozen_string_literal: true

source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?('/')
  "https://github.com/#{repo_name}.git"
end

ruby '2.7.4'

gem 'application_insights', '~> 0.5.6'
gem 'azure_env_secrets', github: 'ministryofjustice/azure_env_secrets', tag: 'v0.1.3'
gem 'azure-storage-blob', '~> 2'
gem 'logstash-logger'
gem 'mimemagic', '~> 0.3.3'
gem 'pry'
gem 'puma'
gem 'rake'
gem 'rest-client'
gem 'sanitize'
gem 'sentry-ruby', '~> 4.6'
gem 'sinatra'

group :development, :test do
  source 'https://oss:Q7U7p2q2XlpY45kwqjCpXLIPf122rjkR@gem.mutant.dev' do
    gem 'mutant-license'
  end

  gem 'dotenv'
  gem 'mutant-rspec'
  gem 'pry-byebug'
  gem 'rspec'
end

group :test do
  gem 'brakeman'
  gem 'capybara'
  gem 'fuubar'
  gem 'rack-test'
  gem 'rspec_junit_formatter', '~> 0.4.1'
  gem 'rubocop', require: false
  gem 'rubocop-rspec', require: false
  gem 'simplecov', require: false
  gem 'webmock'
end
