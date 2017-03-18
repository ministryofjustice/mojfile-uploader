require 'sinatra'
require 'raven'
require_relative 'app'

use Raven::Rack
run MojFile::Uploader
