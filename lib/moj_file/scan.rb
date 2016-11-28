require 'rest_client'
require_relative 'dummy_path'
require 'pp'

module MojFile
  class Scan
    # clamav-rest is remapped in docker-compose.yml
    SCANNER_URL = ENV.fetch('SCANNER_URL', 'http://clamav-rest:8080/scan').freeze

    attr_reader :filename, :dummy_file

    def initialize(filename:, data:)
      @filename = filename
      @dummy_file = DummyPath.new(data)
    end

    def scan_clear?
      post.body.match(/true/)
    end

    private

    def post
      RestClient.post(SCANNER_URL, name: filename, file: dummy_file, multipart: true)
    end
  end
end
