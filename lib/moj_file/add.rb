require 'securerandom'
require 'base64'

module MojFile
  class Add
    include MojFile::S3
    extend Forwardable

    attr_accessor :collection,
      :file_data,
      :filename,
      :errors,
      :subfolder,
      :title

    def initialize(collection_ref:, params:)
      @collection = collection_ref || SecureRandom.uuid
      @file_data = params.fetch('file_data', '')
      @filename = params.fetch('file_filename', '')
      @subfolder = params.fetch('subfolder', nil)
      @title = params.fetch('file_title', '')
      @errors = []
    end

    def upload
      object.put(body: decoded_file_data)
    end

    def valid?
      validate
      errors.empty?
    end

    def scan_clear?
      scan.scan_clear?
    end

    def self.write_test
      # It started checking for .success? but that isn't acutually necessary as
      # anything other than a successful call will raise an exception.
      new(collection_ref: 'healthcheck',
          params: {
        'file_title' => 'Healthcheck Upload',
        'file_filename' => 'healthcheck.docx',
        'file_data' => 'QSBkb2N1bWVudCBib2R5' }
         ).upload
    rescue Aws::S3::Errors::ServiceError
      false
    end

    private

    def scan
      Scan.new(filename: filename, data: decoded_file_data)
    end

    def decoded_file_data
      Base64.decode64(file_data)
    end

    def bucket_name
      ENV.fetch('BUCKET_NAME')
    end

    def object
      s3.bucket(bucket_name).object([collection, subfolder, filename].compact.join('/'))
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
