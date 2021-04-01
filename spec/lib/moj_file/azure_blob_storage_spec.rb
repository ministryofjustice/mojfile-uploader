# frozen_string_literal: true

require 'spec_helper'

RSpec.describe MojFile::AzureBlobStorage do
  let(:object) do
    Class.new do
      include MojFile::AzureBlobStorage
    end
  end

  it 'adds a Blob Service to the class' do
    expect(object.new.storage).to be_an_instance_of(Azure::Storage::Blob::BlobService)
  end

  it 'fetches the account and access key from the ENV' do
    object.new.storage
  end
end
