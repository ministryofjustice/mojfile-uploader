module MojFile
  class Delete
    include MojFile::S3
    include MojFile::Logging

    ACTION_NAME = 'Delete'

    attr_accessor :collection,
      :folder,
      :filename,
      :logger

    def self.delete!(*args)
      new(*args).delete!
    end

    def initialize(collection:, folder:, filename:, logger: DummyLogger.new)
      @collection = collection
      @folder = folder
      @filename = filename
      @logger = logger
    end

    def delete!
      object.delete.tap { log_result(filename: object_name) }
    end
  end
end
