require 'rest_client'
require_relative 'dummy_path'
require 'pp'

module MojFile
  class Scan
    include MojFile::Logging
    # clamav-rest is remapped in docker-compose.yml
    DEFAULT_SCANNER_URL = 'http://clamav-rest:8080/scan'.freeze
    EICAR_TEST = 'X5O!P%@AP[4\PZX54(P^)7CC)7}$EICAR-STANDARD-ANTIVIRUS-TEST-FILE!$H+H*'
    CLEAN_TEST = 'clear test file'
    ACTION_NAME = 'Scan'

    attr_reader :filename, :dummy_file
    attr_accessor :logger

    def initialize(filename:, data:, logger: DummyLogger.new)
      @filename = filename
      @dummy_file = DummyPath.new(data)
      @logger = logger
    end

    def scan_clear?
      post.body.match(/true/)
    rescue => error
      log_result(error: error.inspect, backtrace: error.backtrace)
      raise
    end

    def self.statuscheck_infected
      !new(filename: 'eicar test', data: EICAR_TEST).scan_clear?
    end

    def self.statuscheck_clean
      new(filename: 'clean test', data: CLEAN_TEST).scan_clear?
    end

    def scanner_url
      ENV.fetch('SCANNER_URL', DEFAULT_SCANNER_URL)
    end

    private

    def post
      RestClient.post(scanner_url, name: filename, file: dummy_file, multipart: true)
    end
  end
end
