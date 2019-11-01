require 'spec_helper'

# These may be blank, or the cause of an error, but they still get logged.
RSpec.shared_examples 'common logging actions' do |log_level|
  it 'logs the action' do
    expect(logger).to receive(log_level).with(hash_including(action: 'Add'))
    subject.upload rescue StandardError
  end

  it 'logs the filename' do
    expect(logger).to receive(log_level).with(hash_including(filename: 'ABC123/some_folder/testfile.docx'))
    subject.upload rescue StandardError
  end

  it 'logs the size of file_data in bytes' do
    expect(logger).to receive(log_level).with(hash_including(filesize: 22))
    subject.upload rescue StandardError
  end
end

RSpec.describe MojFile::Add, '#upload' do
  let(:encoded_file_data) { 'QSBkb2N1bWVudCBib2R5\n' }
  let(:decoded_file_data) { 'A document body' }
  let(:params) {
    {
      'file_filename' => 'testfile.docx',
      'folder' => 'some_folder',
      'file_data' => encoded_file_data
    }
  }

  let(:blob_storage_response) { double.as_null_object }
  let(:container_name) { 'dummy-container' }
  let(:blob_name) { 'ABC123/some_folder/testfile.docx' }

  subject {
    described_class.new(collection_ref: nil, params: params)
  }

  before do
    allow(SecureRandom).to receive(:uuid).and_return('ABC123')
  end

  it 'puts the decoded file data to the container' do
    expect(blob_storage_response).to receive(:create_block_blob).with(container_name, blob_name, 'A document body').and_return(Azure::Storage::Blob::Blob)
    allow(subject).to receive(:storage).and_return(blob_storage_response)
    subject.upload
  end

  it 'returns a Blob object when the write is successful' do
    allow(blob_storage_response).to receive(:create_block_blob).and_return(Azure::Storage::Blob::Blob)
    allow(subject).to receive(:storage).and_return(blob_storage_response)
    expect(subject.upload).to eq(Azure::Storage::Blob::Blob)
  end

  describe 'logging' do
    let(:logger) { double.as_null_object }

    before do
      subject.logger = logger
    end

    context 'success' do
      before do
        allow(blob_storage_response).to receive(:create_block_blob).and_return(Azure::Storage::Blob::Blob)
        allow(subject).to receive(:storage).and_return(blob_storage_response)
      end

      it 'logs at info level' do
        expect(logger).to receive(:info)
        subject.upload
      end

      include_examples 'common logging actions', :info
    end

    context 'errors' do
      before do
        allow(SecureRandom).to receive(:uuid).and_return('ABC123')
        allow(subject).to receive(:storage).and_raise(StandardError)
      end

      it 'logs at error level' do
        expect(logger).to receive(:error)
        subject.upload rescue StandardError
      end

      it 'logs the error message' do
        expect(logger).to receive(:error).with(hash_including(error: /StandardError/))
        subject.upload rescue StandardError
      end

      it 'logs the backtrace' do
        expect(logger).to receive(:error).with(hash_including(backtrace: an_instance_of(Array)))
        subject.upload rescue StandardError
      end

      include_examples 'common logging actions', :error
    end
  end
end
