module MojFile
  module S3
    def s3
      Aws::S3::Resource.new(region: ENV.fetch('AWS_REGION', 'eu-west-1'))
    end
  end
end
