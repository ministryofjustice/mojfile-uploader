module MojFile
  class Delete
    include MojFile::S3

    attr_accessor :collection,
      :file

    def self.delete!(*args)
      new(*args).delete!
    end

    def initialize(collection:, file:)
      @collection = collection
      @file = file
    end

    def delete!
      object.delete
    end

    private

    def bucket_name
      ENV.fetch('BUCKET_NAME')
    end

    def object
      s3.bucket(bucket_name).object([collection, file].join('/'))
    end
  end
end
