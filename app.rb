require 'sinatra'
require 'json'
require 'logstash-logger'
require_relative 'lib/moj_file'
require 'pry'

module MojFile
  class Uploader < Sinatra::Base
    configure do
      set :raise_errors, true
      set :show_exceptions, false
    end

    get '/healthcheck' do
      {
        service_status: 'OK',
        dependencies: {
          external: {
            av: {
              detect_infection: Scan.trigger_alert,
              pass_clean: Scan.clean_file
            },
            s3: {
              S3::REGION.tr('-','_') => S3.status
            }
          }
        }
      }.to_json
    end

    get '/:collection_ref' do |collection_ref|
      list = List.call(collection_ref)

      if list.files?
        status(200)
        body(list.files.to_json)
      else
        status(404)
        body({
          errors: ["Collection '#{collection_ref}' does not exist or is empty."]
        }.to_json)
      end
    end

    post '/?:collection_ref?/new' do |collection_ref|
      add = Add.new(collection_ref: collection_ref,
                    params: body_params)

      clear = add.scan_clear?

      if add.valid? && clear
        add.upload
        status(200)
        body({ collection: add.collection, key: add.filename }.to_json)
      elsif !clear
        status(400)
        body({ errors: ['Virus scan failed'] }.to_json)
      else
        status(422) # Unprocessable entity
        body({ errors: add.errors }.to_json)
      end
    end

    delete '/:collection_ref/:filename' do |collection_ref, filename|
      Delete.delete!(collection: collection_ref, file: filename)
      status(204)
    end

    helpers do
      def body_params
        JSON.parse(request.body.read)
      end
    end
  end
end
