require 'securerandom'
require 'base64'
require 'sanitize'

module MojFile
  class Add
    include MojFile::S3
    extend Forwardable

    attr_accessor :collection,
      :filename,
      :folder,
      :file_data,
      :errors

    def initialize(collection_ref:, params:)
      @collection = collection_ref || SecureRandom.uuid
      # The nils and blank strings are necessary to ensure that `app#new`
      # raises the correct errors on validation.
      @filename = sanitize(params.fetch('file_filename', ''))
      @folder = params.fetch('folder', nil)
      @file_data = params.fetch('file_data', '')
      @errors = []
    end

    def upload
      object.put(body: decoded_file_data, server_side_encryption: 'AES256')
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
        'file_filename' => 'healthcheck.docx',
        'file_data' => 'QSBkb2N1bWVudCBib2R5' }
         ).upload
    rescue Aws::S3::Errors::ServiceError
      false
    end

    private

    def sanitize(value)
      CGI.escapeHTML(
        Sanitize.fragment(value, Sanitize::Config::RESTRICTED)
      ).gsub('*', '&#42;').
      gsub('=', '&#61;').
      gsub('-', '&dash;').
      gsub('%', '&#37;').
      gsub(/drop\s+table/i, '').
      gsub(/insert\s+into/i, '')
    end

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
      s3.bucket(bucket_name).object([collection, folder, filename].compact.join('/'))
    end

    def validate
      errors.tap { |e|
        e << 'file_filename must be provided' if filename.empty?
        e << 'file_data must be provided' if file_data.empty?
      }
    end
  end
end
