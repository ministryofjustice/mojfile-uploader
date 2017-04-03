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
    let(:s3_object) { double('S3', delete: true) }

    before do
      allow(subject).to receive_message_chain(:s3, :bucket, :object).and_return(s3_object)
    end

    it 'deletes the s3 object' do
      expect(s3_object).to receive(:delete)
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
