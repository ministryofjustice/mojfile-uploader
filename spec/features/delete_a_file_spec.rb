# frozen_string_literal: true

require 'spec_helper'

RSpec.describe MojFile::Delete do
  context 'the file exists' do
    context 'and is in a subfolder' do
      let!(:blob_storage_stub) do
        stub_request(:delete,
                     %r{dummy-account.blob.core.windows\.net/dummy-container/ABC123/subfolder/testfile\.docx})
          .to_return(status: 204)
      end

      describe '#delete' do
        before do
          delete '/ABC123/subfolder/testfile.docx'
        end

        describe 'it deletes the file' do
          it { expect(blob_storage_stub).to have_been_requested }
          it { expect(last_response.status).to eq(204) }
        end
      end
    end

    context 'and is not in a subfolder' do
      let!(:blob_storage_stub) do
        stub_request(:delete, %r{dummy-account.blob.core.windows\.net/dummy-container/ABC123/testfile\.docx})
          .to_return(status: 204)
      end

      describe '#delete' do
        before do
          delete '/ABC123/testfile.docx'
        end

        describe 'it deletes the file' do
          it { expect(blob_storage_stub).to have_been_requested }
          it { expect(last_response.status).to eq(204) }
        end
      end
    end
  end

  describe 'the file does not exist' do
    let!(:blob_storage_stub) do
      stub_request(:delete, %r{dummy-account.blob.core.windows\.net/dummy-container/ABC123/nofile\.docx})
        .to_return(status: 204)
    end

    describe '#delete' do
      before do
        delete '/ABC123/nofile.docx'
      end

      describe 'it appears to delete the file' do
        it { expect(blob_storage_stub).to have_been_requested }
        it { expect(last_response.status).to eq(204) }
      end
    end
  end

  describe 'neither collection nor file exists' do
    let!(:blob_storage_stub) do
      stub_request(:delete, %r{dummy-account.blob.core.windows\.net/dummy-container/123ABC/nofile\.docx})
        .to_return(status: 204)
    end

    describe '#delete' do
      before do
        delete '/123ABC/nofile.docx'
      end

      describe 'it appears to delete the file' do
        it { expect(blob_storage_stub).to have_been_requested }
        it { expect(last_response.status).to eq(204) }
      end
    end
  end
end
