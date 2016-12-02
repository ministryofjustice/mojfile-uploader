require 'mojfile_uploader_api_client'
require 'sinatra'
require_relative 'app'

MojFileUploaderApiClient::HttpClient.base_url = 'http://localhost:9292'

run MojFileUploadExample::Uploader
