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
      object.put(body: decode(file_data))
    end

    def valid?
      validate
      errors.empty?
    end

    def scan_clear?
      scan.scan_clear?
    end

    private

    def scan
      Scan.new(filename: filename, data: file_data)
    end

    def decode(data)
      Base64.decode64(data)
    end

    def bucket_name
      ENV.fetch('BUCKET_NAME')
    end

    def object
      s3.bucket(bucket_name).object([collection, filename].join('/'))
    end

    def validate
      errors.tap { |e|
        e << 'file_title must be provided' if title.empty?
        e << 'file_filename must be provided' if filename.empty?
        if file_data.empty?
          e << 'file_data must be provided'
        end
      }
    end
  end
end
