require 'sinatra'
require 'json'
require 'logstash-logger'
require_relative 'lib/moj_file'
require 'pry'

module LogStashLogger
  module Formatter
    class PrettyJson < Base
      def call(severity, time, progname, message)
        super
        "#{JSON.pretty_generate(@event)}\n"
      end
    end
  end
end

module MojFile
  class Uploader < Sinatra::Base
    configure do
      set :raise_errors, false
    end

    get '/status.?:format?' do
      checks = statuschecks
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

    get '/:collection_ref/?:folder?' do |collection_ref, folder|
      list = List.call(collection_ref, folder: folder)

      if list.files?
        status(200)
        body(list.files.to_json)
      else
        error = if folder
                  "Collection '#{collection_ref}' and/or folder '#{folder}' does not exist or is empty."
                else
                  "Collection '#{collection_ref}' does not exist or is empty."
                end
        status(404)
        body({
          errors: [error]
        }.to_json)
      end
    end

    post '/?:collection_ref?/new' do |collection_ref|
      add = Add.new(collection_ref: collection_ref,
                    params: body_params,
                    logger: logger)

      clear = add.scan_clear?

      if add.valid? && clear
        add.upload
        status(200)
        body({ collection: add.collection, key: add.filename, folder: add.folder }.to_json)
      elsif !clear
        status(400)
        body({ errors: ['Virus scan failed'] }.to_json)
      else
        status(422) # Unprocessable entity
        body({ errors: add.errors }.to_json)
      end
    end

    delete '/:collection_ref/?:folder?/:filename' do |collection_ref, folder, filename|
      Delete.delete!(collection: collection_ref,
                     folder: folder,
                     filename: filename,
                     logger: logger)
      status(204)
    end

    helpers do
      def logger
        @logger ||= LogStashLogger.new(logger_config)
      end

      def logger_config
        env = ENV['RACK_ENV']
        defaults = { formatter: LogStashLogger::Formatter::PrettyJson }
        if env == 'production'
          defaults.merge!(type: :stdout)
        else
          defaults.merge!({ type: :file, path: "log/#{env}.log", sync: true })
        end
      end

      def body_params
        JSON.parse(request.body.read)
      end

      # Can't see a good way around this.
      # rubocop:disable Metrics/CyclomaticComplexity
      def statuschecks
        write_test = Add.write_test
        detect_infected = Scan.statuscheck_infected
        clean_file = Scan.statuscheck_clean
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
