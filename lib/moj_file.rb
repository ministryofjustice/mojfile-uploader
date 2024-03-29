# frozen_string_literal: true

require 'azure/storage/blob'
require_relative 'moj_file/azure_blob_storage'
require_relative 'moj_file/logging'

require_relative 'moj_file/add'
require_relative 'moj_file/delete'
require_relative 'moj_file/list'
require_relative 'moj_file/scan'
require_relative 'dummy_logger'

module MojFile
end
