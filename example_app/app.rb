require 'sinatra'
require 'base64'
require 'pry'

module MojFileUploadExample
  class Uploader < Sinatra::Base
    use Rack::Logger

    helpers do
      def generate_collection_ref
        SecureRandom.uuid
      end

      def collection_ref
        params['collection_ref']
      end

      def file
        params['file']
      end

      def file_data
        @file_data ||= Base64.encode64(file[:tempfile].read)
      end

      def file_args
        {collection_ref: collection_ref, title: file[:name], filename: file[:filename], data: file_data}
      end

      def log(msg)
        request.logger.info(msg)
      end
    end

    get '/' do
      haml :index, locals: {collection_ref: generate_collection_ref}
    end

    get '/:collection_ref' do |collection_ref|
      begin
        result = MojFileUploaderApiClient::ListFiles.new(collection_ref: collection_ref).call
        log('List result: ' + result.inspect)
      rescue MojFileUploaderApiClient::RequestError => ex
        log('List error: ' + ex.message)
      end

      haml :list_files, locals: {collection_ref: collection_ref, result: result}
    end

    post '/upload' do
      log('Upload arguments: ' + file_args.inspect)
      result = MojFileUploaderApiClient::AddFile.new(file_args).call
      log('Upload result: ' + result.inspect)

      status(201)
      body(result.body.to_json)
    end

    delete '/:collection_ref/:filename' do |collection_ref, filename|
      log('Delete arguments: collection_ref: %s - filename: %s' % [collection_ref, filename])
      result = MojFileUploaderApiClient::DeleteFile.new(collection_ref: collection_ref, filename: filename).call
      log('Delete result: ' + result.inspect)

      status(200)
      body(result.body.to_json)
    end
  end
end
