module MojFile
  class List
    include MojFile::AzureBlobStorage
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
      log_result({ message: "Retrieving files #{prefix} from Azure Blob Storage" })

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
      !blobs.empty?
    end

    private

    def map_files
      blobs.map{ |o|
        {
          key: o.name,
          title: o.name.sub(prefix,''),
          last_modified: o.properties[:last_modified]
        }
      }
    end

    def prefix
      [collection, folder].compact.join('/') + '/'
    end

    def container_name
      ENV.fetch('CONTAINER_NAME')
    end

    def blobs
      @blobs ||= storage.list_blobs(container_name, prefix: prefix)
    end
  end
end
