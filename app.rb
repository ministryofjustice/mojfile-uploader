require 'sinatra'
require 'json'
require 'logstash-logger'
require_relative 'lib/moj_file'
require 'pry'

module MojFile
  class Uploader < Sinatra::Base
    configure do
      set :raise_errors, false
    end

    get '/status.?:format?' do
      checks = statuschecks
      {
        service_status: checks[:service_status],
        version: version,
        dependencies: {
          external: {
            av: {
              detected_infected_file: checks[:detected_infected_file],
              passed_clean_file: checks[:passed_clean_file]
            },
            blob_storage: {
              write_test: checks[:write_test]
            }
          }
        }
      }.to_json
    end

    get '/:collection_ref/?:folder?' do |collection_ref, folder|
      logger.info("Received request to list #{collection_ref}/#{folder} folder")
      list = List.call(collection_ref, folder: folder, logger: logger)

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

    error do
      { message: env['sinatra.error'].message }.to_json
    end

    helpers do
      def logger
        @logger ||= LogStashLogger.new(logger_config)
      end

      def logger_config
        env = ENV['RACK_ENV']

        defaults = {
          formatter: :json_lines,
          customize_event: Proc.new{ |event| event['tags'] = ['moj_uploader'] }
        }

        if env == 'production'
          defaults.merge!(type: :stdout)
        else
          defaults.merge!({ type: :file, path: "log/#{env}.log", sync: true })
        end
      end

      def body_params
        JSON.parse(request.body.read)
      end

      def statuschecks
        service_status = [write_test, detect_infected, clean_file].any?{ |s| s == 'failed' } ? 'failed' : 'ok'
        {
          service_status: service_status,
          write_test: write_test,
          detected_infected_file: detect_infected,
          passed_clean_file: clean_file
        }
      end

      def write_test
        @write_test ||= Add.write_test ? 'ok' : 'failed'
      end

      def detect_infected
        @detect_infected ||= Scan.statuscheck_infected ? 'ok' : 'failed'
      end

      def clean_file
        @clean_file ||= Scan.statuscheck_clean ? 'ok' : 'failed'
      end

      def version
        # This has been manually checked in a demo app in a docker container running
        # ruby:latest with Docker 1.12. Ymmv, however; in particular it may not
        # work on alpine-based containers.
        # NOTE:  This will always work on specs that are run in a git repo.  It
        # should be stubbed at this level if you need a to test it.   See
        # `spec/features/status_spec.rb` for an example.
        `git rev-parse HEAD`.chomp
      end
    end
  end
end
