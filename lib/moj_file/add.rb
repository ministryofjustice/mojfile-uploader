require 'securerandom'
require 'base64'

module MojFile
  class Add
    include MojFile::S3
    extend Forwardable

    attr_accessor :collection,
      :title,
      :filename,
      :file_data,
      :errors

    def initialize(collection_ref:, params:)
      @collection = collection_ref || SecureRandom.uuid
      @title = params.fetch('file_title', '')
      @filename = params.fetch('file_filename', '')
      @file_data = params.fetch('file_data', '')
      @errors = []
    end

    def upload
      object.put(body: file_data)
    end

    def valid?
      validate
      errors.empty?
    end

    def file_key
      @file_key ||= "#{SecureRandom.uuid}.#{title}#{original_extension}"
    end

    private

    def bucket_name
      ENV.fetch('BUCKET_NAME')
    end

    def object
      s3.bucket(bucket_name).object([collection, filename].join('/'))
    end

    def original_extension
      filename[/\.\w+$/]
    end

    def validate
      errors.tap { |e|
        e << 'file_title must be provided' if title.empty?
        e << 'file_filename must be provided' if filename.empty?
        if file_data.empty?
          e << 'file_data must be provided'
        elsif !base_64_encoded?
          e << 'file_data must be base64 encoded'
        end
      }
    end

    def base_64_encoded?
      file_data.match(
        /\A([A-Za-z0-9+]{4})*([A-Za-z0-9+]{4}|[A-Za-z0-9+]{3}=|[A-Za-z0-9+]{2}==)$/
      )
    end
  end
end
