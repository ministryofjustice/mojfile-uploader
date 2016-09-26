require 'rest_client'
require_relative 'dummy_path'

module MojFile
  class Scan
    # clamav-rest is remapped in docker-compose.yml
    SCANNER_URL = 'http://clamav-rest:8080/scan'.freeze

    attr_accessor :filename, :data

    def initialize(filename:, data:)
      @filename = filename
      @data = DummyPath.new(data)
    end

    def scan_clear?
      post.body.eql?("Everything ok : true\n")
    end

    private

    def post
      RestClient.post(SCANNER_URL, name: filename, file: data, multipart: true)
    end
  end
end
