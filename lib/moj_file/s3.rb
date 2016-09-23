module MojFile
  module S3
    def s3
      Aws::S3::Resource.new(
        credentials:
          Aws::Credentials.new(
            ENV.fetch('ACCESS_KEY_ID'),
            ENV.fetch('SECRET_ACCESS_KEY')
          ),
        region: ENV.fetch('AWS_REGION', 'eu-west-1')
      )
    end
  end
end
