# frozen_string_literal: true

module MojFile
  class Delete
    include MojFile::AzureBlobStorage
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
      storage.delete_blob(container_name, blob_name).tap { log_result(filename: blob_name) }
    end
  end
end
