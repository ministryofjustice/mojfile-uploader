# frozen_string_literal: true

module MojFile
  module AzureBlobStorage
    def storage
      Azure::Storage::Blob::BlobService.create
    end

    private

    def container_name
      ENV.fetch('CONTAINER_NAME')
    end

    def blob_name
      [collection, folder, filename].compact.join('/')
    end
  end
end
