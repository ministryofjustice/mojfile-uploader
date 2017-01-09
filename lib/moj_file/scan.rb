require 'rest_client'
require_relative 'dummy_path'
require 'pp'

module MojFile
  class Scan
    # clamav-rest is remapped in docker-compose.yml
    SCANNER_URL = ENV.fetch('SCANNER_URL', 'http://clamav-rest:8080/scan').freeze
    EICAR_TEST = 'X5O!P%@AP[4\PZX54(P^)7CC)7}$EICAR-STANDARD-ANTIVIRUS-TEST-FILE!$H+H*'
    CLEAN_TEST = 'clear test file'

    attr_reader :filename, :dummy_file

    def initialize(filename:, data:)
      @filename = filename
      @dummy_file = DummyPath.new(data)
    end

    def scan_clear?
      post.body.match(/true/)
    end

    def self.healthcheck_infected
      !new(filename: 'eicar test', data: EICAR_TEST).scan_clear?
    end

    def self.healthcheck_clean
      new(filename: 'clean test', data: CLEAN_TEST).scan_clear?
    end

    private

    def post
      RestClient.post(SCANNER_URL, name: filename, file: dummy_file, multipart: true)
    end
  end
end
