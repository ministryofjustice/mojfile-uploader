# frozen_string_literal: true
source 'https://rubygems.org'

gem 'pry'
gem 'puma'
gem 'rake'
gem 'rest-client'
gem 's3', '~> 0.3.24'
gem 'sinatra'

group :development, :test do
  gem 'mutant-rspec'
  gem 'pry-byebug'
  gem 'rspec'
end

group :test do
  gem 'brakeman'
  gem 'capybara'
  gem 'fuubar'
  gem 'rubocop', require: false
  gem 'rubocop-rspec', require: false
  gem 'simplecov', require: false
end
