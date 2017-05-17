require 'spec_helper'

RSpec.describe MojFile::List do
  class ExampleError < StandardError; end

  let(:collection_ref) { '12345' }
  let(:folder) { 'subfolder' }
  let(:s3) { instance_double(Aws::S3::Resource, bucket: bucket) }
  let(:bucket) { double('Bucket', objects: objects) }
  let(:objects) { [double('Object', key: '12345/subfolder/test123.txt', last_modified: '2016-12-01T16:26:44.000Z')] }

  subject { described_class.new(collection_ref, folder: folder) }

  describe '.initialize' do
    specify '#logger is set to DummyLogger by default' do
      expect(subject.logger).to be_a_kind_of(DummyLogger)
    end
  end

  describe '#files' do
    before do
      allow(subject).to receive(:s3).and_return(s3)
    end

    let(:expected_files_hash) {
      {
        collection: collection_ref,
        folder: folder,
        files: [
          {key: '12345/subfolder/test123.txt', title: 'test123.txt', last_modified: '2016-12-01T16:26:44.000Z'}
        ],
        action: 'List'
      }
    }

    it 'list S3 bucket objects by their collection reference including a trailing slash' do
      expect(bucket).to receive(:objects).with(prefix: '12345/subfolder/')
      files = subject.files
      expect(files).to eq(expected_files_hash)
    end

    context 'when no folder is given' do
      let(:expected_files_hash) {
        {
          collection: collection_ref,
          folder: folder,
          files: [
            {key: '12345/test123.txt', title: 'test123.txt', last_modified: '2016-12-01T16:26:44.000Z'}
          ],
          action: 'List'
        }
      }
      let(:objects) { [double('Object', key: '12345/test123.txt', last_modified: '2016-12-01T16:26:44.000Z')] }
      let(:folder) { nil }

      it 'list S3 bucket objects by their collection reference including a trailing slash' do
        expect(bucket).to receive(:objects).with(prefix: '12345/')
        files = subject.files
        expect(files).to eq(expected_files_hash)
      end
    end

    context 'errors' do
      let(:logger) { double.as_null_object }

      before do
        subject.logger = logger
      end

      it 'catches and re-raises errors' do
        expect(logger).to receive(:error).with(hash_including(error: /ExampleError/, backtrace: a_kind_of(Array)))
        expect(bucket).to receive(:objects).and_raise(ExampleError)
        expect { subject.files }.to raise_error(ExampleError)
      end
    end
  end
end
