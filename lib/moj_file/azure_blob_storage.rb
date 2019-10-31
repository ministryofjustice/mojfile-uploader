module MojFile
  module AzureBlobStorage

    def storage
      Azure::Storage::Blob::BlobService.create
    end

    private

    def bucket_name
      ENV.fetch('CONTAINER_NAME')
    end

    def object_name
      [collection, folder, filename].compact.join('/')
    end
  end
end
