require_relative '../spec_helper'

RSpec.describe MojFile::Add do
  let(:encoded_file_data) { 'QSBkb2N1bWVudCBib2R5\n' }
  let(:decoded_file_data) { 'A document body' }
  let(:container_name) { 'dummy-container' }
  let(:scanner_url) { 'http://my-test-scanner' }

  let(:params) {
    {
      folder: 'subfolder',
      file_filename: 'testfile.docx',
      file_data: encoded_file_data
    }
  }

  before do
    allow(SecureRandom).to receive(:uuid).and_return(12345)
    allow(ENV).to receive(:fetch).with('CONTAINER_NAME').and_return(container_name)
    allow(ENV).to receive(:fetch).with('SCANNER_URL', 'http://clamav-rest:8080/scan').and_return(scanner_url)
  end

  let!(:blob_storage_stub) {
    stub_request(:put, /dummy-account.blob.core.windows\.net\/dummy-container\/12345\/subfolder\/testfile.docx/).
      with(body: decoded_file_data)
  }

  let!(:av_stub) {
    # Ideally, I would match the request body for filename and data.  This
    # would remove the need for unit tests for these specific attributes.
    # However, webmock does not yet support this for multipart requests.
    stub_request(:post, "http://my-test-scanner").to_return(body: "true\n")
  }

  context 'successfully adding a file' do
    context 'generating a new collection_reference' do
      it 'uploads the file to azure blob storage' do
        post '/new', params.to_json
        expect(blob_storage_stub).to have_been_requested
      end

      it 'sends the file file to the av service for scanning' do
        post '/new', params.to_json
        expect(av_stub).to have_been_requested
      end

      it 'returns a 200' do
        post '/new', params.to_json
        expect(last_response.status).to eq(200)
      end

      describe 'json response body' do
        it 'contains the file key' do
          post '/new', params.to_json
          expect(last_response.body).to match(/\"key\":\"testfile.docx\"/)
        end

        it 'contains the collection reference' do
          post '/new', params.to_json
          expect(last_response.body).to match(/\"collection\":12345/)
        end

        it 'contains the folder name' do
          post '/new', params.to_json
          expect(last_response.body).to match(/\"folder\":\"subfolder\"/)
        end
      end
    end

    context 'without a folder' do
      before do
        stub_request(:put, /dummy-account.blob.core.windows\.net\/dummy-container\/ABC123\/testfile.docx/)
      end

      let(:params) { super().merge('folder' => nil) }

      it 'returns a 200' do
        post '/ABC123/new', params.to_json
        expect(last_response.status).to eq(200)
      end

      describe 'json response body' do
        it 'contains the folder as null' do
          post '/ABC123/new', params.to_json
          expect(last_response.body).to match(/\"folder\":null/)
        end
      end
    end

    context 'reusing a collection_reference' do
      before do
        stub_request(:put, /dummy-account.blob.core.windows\.net\/dummy-container\/ABC123\/subfolder\/testfile.docx/)
      end

      it 'returns a 200' do
        post '/ABC123/new', params.to_json
        expect(last_response.status).to eq(200)
      end

      describe 'json response body' do
        it 'contains the collection reference' do
          post '/ABC123/new', params.to_json
          expect(last_response.body).to match(/\"collection\":\"ABC123"/)
        end
      end
    end
  end

  context 'missing data' do
    it 'returns a 422 if the filename is missing' do
      params.delete(:file_filename)
      post '/new', params.to_json
      expect(last_response.status).to eq(422)
    end

    it 'returns a 422 if the file data is missing' do
      params.delete(:file_data)
      post '/new', params.to_json
      expect(last_response.status).to eq(422)
    end

    describe 'json response body' do
      it 'explains the filename is missing' do
        params.delete(:file_filename)
        post '/new', params.to_json
        expect(last_response.body).to match(/\"errors\":\[\"file_filename must be provided\"\]/)
      end

      it 'explains the file data is missing' do
        params.delete(:file_data)
        post '/new', params.to_json
        expect(last_response.body).to match(/\"errors\":\[\"file_data must be provided\"\]/)
      end
    end
  end
end
