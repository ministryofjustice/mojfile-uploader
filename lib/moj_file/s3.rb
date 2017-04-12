require 'nokogiri'

module MojFile
  module S3
    # 3 is the default number of retries[1]. I have chosen a conservative 5
    # here as, according to the AWS docs[2], retries use exponential backoff
    # and I do not want the increasing time between attempts to set off the
    # client timeout.
    #
    # [1](http://docs.aws.amazon.com/sdkforruby/api/Aws/S3/Client.html#initialize-instance_method)
    # [2](http://docs.aws.amazon.com/general/latest/gr/api-retries.html) it uses
    RETRY_LIMIT = 5.freeze
    REGION = ENV.fetch('AWS_REGION', 'eu-west-1').freeze
    STATUS_RSS_ENDPOINT =
      "https://status.aws.amazon.com/rss/s3-#{REGION}.rss".freeze

    def s3
      client = Aws::S3::Client.new(region: REGION, retry_limit: RETRY_LIMIT, compute_checksums: false)
      Aws::S3::Resource.new(client: client)
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
