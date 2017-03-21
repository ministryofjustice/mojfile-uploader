require 'spec_helper'

RSpec.describe MojFile::Add do
  let(:encoded_file_data) { 'QSBkb2N1bWVudCBib2R5\n' }
  let(:decoded_file_data) { 'A document body' }

  let(:params) {
    {
      'file_filename' => 'testfile.docx',
      'folder' => 'some_folder',
      'file_data' => encoded_file_data
    }
  }

  describe '#filename' do
    let(:value) { double.as_null_object }

    # Mutant kill
    specify 'returns an empty string if not passed in' do
      mocked_params = double.as_null_object
      expect(mocked_params).to receive(:fetch).with('file_filename', '')
      described_class.new(collection_ref: nil, params: mocked_params)
    end

    specify 'escapes html that was not otherwise removed' do
      expect(CGI).to receive(:escapeHTML).and_return(value)
      described_class.new(collection_ref: nil, params: params)
    end

    specify 'removes most html tags' do
      expect(Sanitize).to receive(:fragment).with(params['file_filename'], anything).and_return(value)
      described_class.new(collection_ref: nil, params: params)
    end

    specify 'scrubs *' do
      allow(CGI).to receive(:escapeHTML).and_return(value)
      expect(value).to receive(:gsub).with('*', anything)
      described_class.new(collection_ref: nil, params: params)
    end

    specify 'scrubs =' do
      allow(CGI).to receive(:escapeHTML).and_return(value)
      expect(value).to receive(:gsub).with('=', anything)
      described_class.new(collection_ref: nil, params: params)
    end

    specify 'scrubs -' do # kills SQL comments
      allow(CGI).to receive(:escapeHTML).and_return(value)
      expect(value).to receive(:gsub).with('-', anything)
      described_class.new(collection_ref: nil, params: params)
    end

    specify 'scrubs %' do
      allow(CGI).to receive(:escapeHTML).and_return(value)
      expect(value).to receive(:gsub).with('%', anything)
      described_class.new(collection_ref: nil, params: params)
    end

    specify 'removes `drop table` case-insensitively'do
      allow(CGI).to receive(:escapeHTML).and_return(value)
      expect(value).to receive(:gsub).with(/drop\s+table/i, anything)
      described_class.new(collection_ref: nil, params: params)
    end

    specify 'removes `insert into` case-insensitively'do
      allow(CGI).to receive(:escapeHTML).and_return(value)
      expect(value).to receive(:gsub).with(/insert\s+into/i, anything)
      described_class.new(collection_ref: nil, params: params)
    end
  end

  describe '#scan_clear?' do
    before do
      scan = instance_double(MojFile::Scan)
      expect(scan).to receive(:scan_clear?)
      expect(MojFile::Scan).to receive(:new).
        with(filename: params['file_filename'], data: decoded_file_data).
        and_return(scan)
    end

    it 'calls MojFile::Scan' do
      described_class.new(collection_ref: nil, params: params).scan_clear?
    end
  end

  describe 'encrypting' do
    subject(:adder) { described_class.new(collection_ref: 'foo', params: params) }
    let(:s3_object) { double('S3', put: true) }

    before do
      stub_request(:put, "https://uploader-test-bucket.s3-eu-west-1.amazonaws.com/foo/testfile.docx")
      # TODO: stubbing methods on the test subject is gross. We should fix this
      allow(adder).to receive_message_chain(:s3, :bucket, :object).and_return(s3_object)
    end

    it 'set the encryption to AES256' do
      expect(s3_object).to receive(:put).with(body: 'A document body', server_side_encryption: 'AES256')
      adder.upload
    end
  end

  describe '.write_test' do # These are mutant kills
    it 'uploads a test file successfully' do
      stub_request(:put, /\/healthcheck\/healthcheck\.docx/).to_return(status: 200)
      expect(described_class.write_test).to be_truthy
    end

    it 'fails to upload a test file' do
      stub_request(:put, /\/healthcheck\/healthcheck\.docx/).to_return(status: 422)
      expect(described_class.write_test).to be(false)
    end

    it 'receives the parameters required for the test file' do
      response = double(:response, successful?: true)
      expect(described_class).
        to receive(:new).
        with(collection_ref: 'healthcheck',
             params: {
        'file_filename' => 'healthcheck.docx',
        'file_data' => 'QSBkb2N1bWVudCBib2R5'
      }
            ).and_return(instance_double(MojFile::Add, upload: response))
      described_class.write_test
    end
  end
end
