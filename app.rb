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

    get '/healthcheck.?:format?' do
      checks = healthchecks
      {
        service_status: checks[:service_status],
        dependencies: {
          external: {
            av: {
              detected_infected_file: checks[:detected_infected_file],
              passed_clean_file: checks[:passed_clean_file]
            },
            s3: {
              # This is here so ops do not have to go looking for the AWS S3
              # status if the write_test fails. It does not change the
              # service_status
              S3::REGION.tr('-','_') => S3.status,
              write_test: checks[:write_test]
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

      # Can't see a good way around this.
      # rubocop:disable Metrics/CyclomaticComplexity
      def healthchecks
        write_test = Add.write_test
        detect_infected = Scan.healthcheck_infected
        clean_file = Scan.healthcheck_clean
        service_status = if write_test && detect_infected && clean_file
                           'ok'
                         else
                           'failed'
                         end
        {
          service_status: service_status,
          write_test: write_test ? 'ok' : 'failed',
          detected_infected_file: detect_infected ? 'ok' : 'failed',
          passed_clean_file: clean_file ? 'ok' : 'failed'
        }
      end
      # rubocop:enable Metrics/CyclomaticComplexity
    end
  end
end
