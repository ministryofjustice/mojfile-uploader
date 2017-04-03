require 'spec_helper'

# These may be blank, or the cause of an error, but they still get logged.
RSpec.shared_examples 'common logging actions' do |log_level|
  it 'logs the action' do
    expect(logger).to receive(log_level).with(hash_including(action: 'Add'))
    subject.upload
  end

  it 'logs the filename' do
    expect(logger).to receive(log_level).with(hash_including(filename: 'ABC123/some_folder/testfile.docx'))
    subject.upload
  end

  it 'logs the size of file_data in bytes' do
    expect(logger).to receive(log_level).with(hash_including(filesize: 22))
    subject.upload
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

  let(:s3_response) { double.as_null_object }

  subject {
    described_class.new(collection_ref: nil, params: params)
  }

  before do
    allow(SecureRandom).to receive(:uuid).and_return('ABC123')
  end

  it 'puts the decoded file data to the bucket' do
    expect(s3_response).to receive(:put).with(hash_including(body: 'A document body')).and_return(true)
    allow(subject).to receive(:object).and_return(s3_response)
    subject.upload
  end

  it 'tells S3 to encrypt the stored data using AES256' do
    expect(s3_response).to receive(:put).with(hash_including(server_side_encryption: 'AES256')).and_return(true)
    allow(subject).to receive(:object).and_return(s3_response)
    subject.upload
  end

  it 'returns false when an error occurs' do
    allow(subject).to receive(:object).and_raise(StandardError)
    expect(subject.upload).to eq(false)
  end

  it 'returns true when the write is successful' do
    allow(s3_response).to receive(:put).and_return(true)
    allow(subject).to receive(:object).and_return(s3_response)
    expect(subject.upload).to eq(true)
  end

  describe 'logging' do
    let(:logger) { double.as_null_object }

    before do
      subject.logger = logger
    end

    context 'success' do
      before do
        allow(s3_response).to receive(:put).and_return(true)
        allow(subject).to receive(:object).and_return(s3_response)
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
        allow(subject).to receive(:object).and_raise(StandardError)
      end

      it 'logs at error level' do
        expect(logger).to receive(:error)
        subject.upload
      end

      it 'logs the error message' do
        expect(logger).to receive(:error).with(hash_including(error: 'StandardError'))
        subject.upload
      end

      it 'logs the backtrace' do
        expect(logger).to receive(:error).with(hash_including(backtrace: an_instance_of(Array)))
        subject.upload
      end

      include_examples 'common logging actions', :error
    end
  end
end
