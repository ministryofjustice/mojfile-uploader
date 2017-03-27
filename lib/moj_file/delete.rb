module MojFile
  class Delete
    include MojFile::S3

    attr_accessor :collection,
      :folder,
      :file

    def self.delete!(*args)
      new(*args).delete!
    end

    def initialize(collection:, folder:, file:)
      @collection = collection
      @folder = folder
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
      s3.bucket(bucket_name).object([collection, folder, file].compact.join('/'))
    end
  end
end
