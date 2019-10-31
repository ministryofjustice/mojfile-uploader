module MojFile
  class List
    include MojFile::Logging

    ACTION_NAME = 'List'

    attr_accessor :collection, :folder, :logger

    def self.call(*args)
      new(*args)
    end

    def initialize(collection_ref, folder:, logger: DummyLogger.new)
      @collection = collection_ref
      @folder = folder
      @logger = logger
    end

    def files
      {
        collection: collection,
        folder: folder,
        files: map_files
      }.tap { |o| log_result(o) }
    rescue => error
      log_result(error: error.inspect, backtrace: error.backtrace)
      raise
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
      [collection, folder].compact.join('/') + '/'
    end

    def bucket_name
      ENV.fetch('BUCKET_NAME')
    end

    def objects
      @objects ||= s3.bucket(bucket_name).objects(prefix: prefix).to_set
    end
  end
end
