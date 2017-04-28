require 'securerandom'
require 'base64'
require 'sanitize'

module MojFile
  class Add
    include MojFile::S3
    include MojFile::Logging
    extend Forwardable

    ACTION_NAME = 'Add'

    attr_accessor :collection,
      :errors,
      :file_data,
      :filename,
      :folder,
      :logger,
      :scanner

    def initialize(collection_ref:, params:, logger: DummyLogger.new)
      @collection = collection_ref || SecureRandom.uuid
      # The nils and blank strings are necessary to ensure that `app#new`
      # raises the correct errors on validation.
      @filename = sanitize(params.fetch('file_filename', ''))
      @folder = params.fetch('folder', nil)
      @file_data = params.fetch('file_data', '')
      @errors = []
      @logger = logger
      @scanner = params.fetch('scanner', Scan)
    end

    def upload
      object.put(body: decoded_file_data, server_side_encryption: 'AES256').tap { log_result }
    rescue => error
      log_result(error: error.inspect, backtrace: error.backtrace)
      false
    end

    def valid?
      validate
      errors.empty?
    end

    def scan_clear?
      # This is not done with `.fetch` as that interferes with stubbing in the
      # feature specs. 'DO_NOT_SCAN' is used in to keep the uploader from
      # breaking in the Heroku demo environment, which cannot run/access the
      # virus scanning container.
      return true if ENV['DO_NOT_SCAN']
      scanner.new(filename: filename, data: decoded_file_data).scan_clear?
    end

    def self.write_test
      # Errors get trapped and logged in `#upload`
      new(collection_ref: 'status',
          params: {
        'file_filename' => 'status.docx',
        'file_data' => 'QSBkb2N1bWVudCBib2R5' }
         ).upload
    end

    private

    def log_result(params = {})
      params.merge!(
        {
          filename: object_name,
          filesize: file_data.size
        }
      )
      super
    end

    def sanitize(value)
      Sanitize.fragment(value).
      gsub('*', '&#42;').
      gsub('=', '&#61;').
      gsub('%', '&#37;').
      gsub(/drop\s+table/i, '').
      gsub(/insert\s+into/i, '')
    end

    def decoded_file_data
      Base64.decode64(file_data)
    end

    def validate
      errors.tap { |e|
        e << 'file_filename must be provided' if filename.empty?
        e << 'file_data must be provided' if file_data.empty?
      }
    end
  end
end
