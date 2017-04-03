require 'nokogiri'

module MojFile
  module S3
    REGION = ENV.fetch('AWS_REGION', 'eu-west-1').freeze
    STATUS_RSS_ENDPOINT =
      "https://status.aws.amazon.com/rss/s3-#{REGION}.rss".freeze

    def s3
      Aws::S3::Resource.new(region: REGION)
    end

    def self.status
      status = RestClient.get(STATUS_RSS_ENDPOINT)
      Nokogiri.parse(status.body).xpath("//item/title").first.text
		rescue NoMethodError
			'N/A'
    end

    def object
      s3.bucket(bucket_name).object(object_name)
    end

    private

    def bucket_name
      ENV.fetch('BUCKET_NAME')
    end

    def object_name
      [collection, folder, filename].compact.join('/')
    end
  end
end
