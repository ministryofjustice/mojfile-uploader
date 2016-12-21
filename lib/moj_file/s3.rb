require 'nokogiri'

module MojFile
  module S3
    REGION = ENV.fetch('AWS_REGION', 'eu-west-1').freeze
    STATUS_RSS_ENDPOINT =
      "https://status.aws.amazon.com/rss/s3-#{REGION}.rss".freeze

    def s3
      Aws::S3::Resource.new(region: REGION)
    end

    class << self
      def status
        status_request = RestClient.get(STATUS_RSS_ENDPOINT)
        status = status_text(status_request)
        # TODO: Review the binary nature of this status and refine it. There are
        # many circumstances where a failure on S3 might not affect the service.
        # For example, a recent alert indicated that bucket names starting with
        # certain prefixes ('village' or 'ptx') were experiencing failures, while
        # the rest of the service was normal.
        if status.match(/\AService is operating normally/)
          'OK'
        else
          'FAILED'
        end
      rescue NoMethodError
        'N/A'
      end

      private

      def status_text(status)
        Nokogiri.parse(status.body).xpath("//item/title").first.text
      end
    end
  end
end
