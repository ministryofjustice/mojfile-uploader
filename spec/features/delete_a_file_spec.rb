require 'spec_helper'

RSpec.describe MojFile::Delete do
  context 'the file exists' do
    context 'and is in a subfolder' do
      let!(:s3_stub) {
        stub_request(:delete, /uploader-test-bucket.+amazonaws\.com\/ABC123\/subfolder\/testfile\.docx/).
        to_return(status: 204)
      }

      describe '#delete' do
        before do
          delete '/ABC123/subfolder/testfile.docx'
        end

        describe 'it deletes the file' do
          it { expect(s3_stub).to have_been_requested }
          # This mirrors S3's success response.
          it { expect(last_response.status).to eq(204) }
        end
      end
    end

    context 'and is not in a subfolder' do
      let!(:s3_stub) {
        stub_request(:delete, /uploader-test-bucket.+amazonaws\.com\/ABC123\/testfile\.docx/).
        to_return(status: 204)
      }

      describe '#delete' do
        before do
          delete '/ABC123/testfile.docx'
        end

        describe 'it deletes the file' do
          it { expect(s3_stub).to have_been_requested }
          # This mirrors S3's success response.
          it { expect(last_response.status).to eq(204) }
        end
      end
    end
  end

  describe 'the file does not exist' do
    let!(:s3_stub) {
      stub_request(:delete, /uploader-test-bucket.+amazonaws\.com\/ABC123\/nofile\.docx/).
      to_return(status: 204)
    }

    describe '#delete' do
      before do
        delete '/ABC123/nofile.docx'
      end

      describe 'it appears to delete the file' do
        it { expect(s3_stub).to have_been_requested }
        it { expect(last_response.status).to eq(204) }
      end
    end
  end

  describe 'neither collection nor file exists' do
    let!(:s3_stub) {
      stub_request(:delete, /uploader-test-bucket.+amazonaws\.com\/123ABC\/nofile\.docx/).
      to_return(status: 204)
    }

    describe '#delete' do
      before do
        delete '/123ABC/nofile.docx'
      end

      describe 'it appears to delete the file' do
        it { expect(s3_stub).to have_been_requested }
        it { expect(last_response.status).to eq(204) }
      end
    end
  end
end
