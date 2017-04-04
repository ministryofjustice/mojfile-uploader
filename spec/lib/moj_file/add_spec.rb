require 'spec_helper'

RSpec.describe MojFile::Add do
  let(:encoded_file_data) { 'QSBkb2N1bWVudCBib2R5\n' }
  let(:decoded_file_data) { 'A document body' }
  let(:filename) { 'testfile.docx' }
  let(:scanner) { double.as_null_object }

  let(:params) {
    {
      'file_filename' => filename,
      'folder' => 'some_folder',
      'file_data' => encoded_file_data,
      'scanner' => scanner
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

    specify 'removes most html tags' do
      expect(Sanitize).to receive(:fragment).with(params['file_filename']).and_return(value)
      described_class.new(collection_ref: nil, params: params)
    end

    specify 'scrubs *' do
      allow(Sanitize).to receive(:fragment).and_return(value)
      expect(value).to receive(:gsub).with('*', anything)
      described_class.new(collection_ref: nil, params: params)
    end

    specify 'scrubs =' do
      allow(Sanitize).to receive(:fragment).and_return(value)
      expect(value).to receive(:gsub).with('=', anything)
      described_class.new(collection_ref: nil, params: params)
    end

    specify 'scrubs %' do
      allow(Sanitize).to receive(:fragment).and_return(value)
      expect(value).to receive(:gsub).with('%', anything)
      described_class.new(collection_ref: nil, params: params)
    end

    specify 'removes `drop table` case-insensitively'do
      allow(Sanitize).to receive(:fragment).and_return(value)
      expect(value).to receive(:gsub).with(/drop\s+table/i, anything)
      described_class.new(collection_ref: nil, params: params)
    end

    specify 'removes `insert into` case-insensitively'do
      allow(Sanitize).to receive(:fragment).and_return(value)
      expect(value).to receive(:gsub).with(/insert\s+into/i, anything)
      described_class.new(collection_ref: nil, params: params)
    end
  end

  describe '#scan_clear?' do
    let(:scanner_instance) { double.as_null_object }
    subject { described_class.new(collection_ref: nil, params: params) }

    specify 'it creates a new instance of the scanner' do
      expect(scanner).to receive(:new).with(filename: filename, data: decoded_file_data).and_return(scanner_instance)
      subject.scan_clear?
    end

    specify 'it delegates the call to scanner instance' do
      allow(scanner).to receive(:new).and_return(scanner_instance)
      expect(scanner_instance).to receive(:scan_clear?)
      subject.scan_clear?
    end

    context 'DO_NOT_SCAN is set' do
      before do
        allow(ENV).to receive(:[]).with('DO_NOT_SCAN').and_return(1)
      end

      specify 'skips the scanner' do
        expect(scanner_instance).not_to receive(:scan_clear?)
        subject.scan_clear?
      end

      specify 'always returns true' do
        expect(subject.scan_clear?).to be(true)
      end
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
      stub_request(:put, /\/status\/status\.docx/).to_return(status: 200)
      expect(described_class.write_test).to be_truthy
    end

    it 'fails to upload a test file' do
      stub_request(:put, /\/status\/status\.docx/).to_return(status: 422)
      expect(described_class.write_test).to be(false)
    end

    it 'receives the parameters required for the test file' do
      response = double(:response, successful?: true)
      expect(described_class).
        to receive(:new).
        with(collection_ref: 'status',
             params: {
        'file_filename' => 'status.docx',
        'file_data' => 'QSBkb2N1bWVudCBib2R5'
      }
            ).and_return(instance_double(MojFile::Add, upload: response))
      described_class.write_test
    end
  end
end
