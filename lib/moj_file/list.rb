module MojFile
  class List
    include MojFile::S3

    attr_accessor :collection

    def self.call(*args)
      new(*args)
    end

    def initialize(collection_ref)
      @collection = collection_ref
    end

    def files
      {
        collection: collection,
        files: map_files
      }
    end

    def files?
      !objects.empty?
    end

    private

    def map_files
      objects.map{ |o|
        {
          key: o.key,
          title: o.key.sub(prefix,''),
          last_modified: o.last_modified
        }
      }
    end

    def prefix
      "#{collection}/"
    end

    def bucket_name
      ENV.fetch('BUCKET_NAME')
    end

    def objects
      @objects ||= s3.bucket(bucket_name).objects(prefix: prefix).to_set
    end
  end
end
