# frozen_string_literal: true
source 'https://rubygems.org'

ruby '2.5.7'

gem 'aws-sdk'
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
  gem 'rubocop', require: false
  gem 'rubocop-rspec', require: false
  gem 'simplecov', require: false
  gem 'webmock'
end
