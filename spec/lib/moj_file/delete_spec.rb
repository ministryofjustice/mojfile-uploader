require 'spec_helper'

RSpec.describe MojFile::Delete do
  let(:args) {
    {
      collection: 'collection',
      folder: 'some_folder',
      filename: 'testfile.docx'
    }
  }

  subject { described_class.new(args) }

  describe 'deleting' do
    let(:storage) { instance_double(Azure::Storage::Blob::BlobService, delete_blob: nil) }
    let(:container_name) { 'dummy-container' }
    let(:blob_name) { 'collection/some_folder/testfile.docx' }

    before do
      allow(subject).to receive(:storage).and_return(storage)
    end

    it 'deletes the blob' do
      expect(storage).to receive(:delete_blob).with(container_name, blob_name)
      subject.delete!
    end

    describe 'logging' do
      let(:logger) { double.as_null_object }

      before do
        subject.logger = logger
      end

      it 'logs at info level the details of the file' do
        expect(logger).to receive(:info).with(
          hash_including(filename: 'collection/some_folder/testfile.docx', action: 'Delete')
        )
        subject.delete!
      end
    end
  end
end
