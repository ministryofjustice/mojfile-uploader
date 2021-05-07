# frozen_string_literal: true

require 'spec_helper'

RSpec.describe MojFile::List do
  class ExampleError < StandardError; end

  let(:collection_ref) { '12345' }
  let(:folder) { 'subfolder' }
  let(:storage) { instance_double(Azure::Storage::Blob::BlobService, list_blobs: blobs) }
  let(:container_name) { 'dummy-container' }
  let(:blobs) do
    [double('Blob', name: '12345/subfolder/test123.txt', properties: { last_modified: '2016-12-01T16:26:44.000Z' })]
  end

  subject { described_class.new(collection_ref, folder: folder) }

  describe '.initialize' do
    specify '#logger is set to DummyLogger by default' do
      expect(subject.logger).to be_a_kind_of(DummyLogger)
    end
  end

  describe '#files' do
    before do
      allow(subject).to receive(:storage).and_return(storage)
    end

    let(:expected_files_hash) do
      {
        collection: collection_ref,
        folder: folder,
        files: [
          { key: '12345/subfolder/test123.txt', title: 'test123.txt', last_modified: '2016-12-01T16:26:44.000Z' }
        ],
        action: 'List'
      }
    end

    it 'list Azure Blob Storage container blobs by their collection reference including a trailing slash' do
      expect(storage).to receive(:list_blobs).with(container_name, prefix: '12345/subfolder/')
      files = subject.files
      expect(files).to eq(expected_files_hash)
    end

    context 'when no folder is given' do
      let(:expected_files_hash) do
        {
          collection: collection_ref,
          folder: folder,
          files: [
            { key: '12345/test123.txt', title: 'test123.txt', last_modified: '2016-12-01T16:26:44.000Z' }
          ],
          action: 'List'
        }
      end
      let(:blobs) do
        [double('Blob', name: '12345/test123.txt', properties: { last_modified: '2016-12-01T16:26:44.000Z' })]
      end
      let(:folder) { nil }

      it 'list Azure Blob Storage container blobs by their collection reference including a trailing slash' do
        expect(storage).to receive(:list_blobs).with(container_name, prefix: '12345/')
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
        expect(storage).to receive(:list_blobs).and_raise(ExampleError)
        expect { subject.files }.to raise_error(ExampleError)
      end
    end
  end
end
