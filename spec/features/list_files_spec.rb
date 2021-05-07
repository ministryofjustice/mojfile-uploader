# frozen_string_literal: true

require_relative '../spec_helper'

RSpec.describe MojFile::List do
  let(:prefix) { '12345/' }
  let!(:blob_storage_stub) do
    stub_request(:get, "https://dummy-account.blob.core.windows.net/dummy-container?comp=list&prefix=#{prefix}&restype=container")
      .to_return(body: blob_storage_response, status: 200)
  end

  context 'happy paths' do
    context 'when a subfolder is provided' do
      let(:prefix) { '12345/subfolder/' }

      describe 'the collection has files' do
        let(:blob_storage_response) do
          <<~XML
            <?xml version="1.0" encoding="utf-8"?>
            <EnumerationResults ServiceEndpoint="https://dummy-account.blob.core.windows.net/" ContainerName="dummy-container">
              <Blobs>
                <Blob>
                  <Name>12345/subfolder/solicitor.docx</Name>
                  <Properties>
                    <Last-Modified>Mon, 04 Nov 2019 12:30:14 GMT</Last-Modified>
                  </Properties>
                </Blob>
                <Blob>
                  <Name>12345/subfolder/hmrc_appeal.docx</Name>
                  <Properties>
                    <Last-Modified>Mon, 04 Nov 2019 13:34:37 GMT</Last-Modified>
                  </Properties>
                </Blob>
              </Blobs>
              <NextMarker />
            </EnumerationResults>
          XML
        end

        let(:expected_response) do
          {
            collection: '12345',
            folder: 'subfolder',
            files: [
              {
                key: '12345/subfolder/solicitor.docx',
                title: 'solicitor.docx',
                last_modified: 'Mon, 04 Nov 2019 12:30:14 GMT'
              },
              {
                key: '12345/subfolder/hmrc_appeal.docx',
                title: 'hmrc_appeal.docx',
                last_modified: 'Mon, 04 Nov 2019 13:34:37 GMT'
              }
            ],
            action: 'List'
          }.to_json
        end

        it 'returns a 200 ok' do
          get '/12345/subfolder'
          expect(last_response.status).to eq(200)
        end

        it 'returns a list of the files in a collection' do
          get '/12345/subfolder'
          expect(last_response.body).to eq(expected_response)
        end
      end
    end

    context 'when no subfolder is provided' do
      describe 'the collection has files' do
        let(:blob_storage_response) do
          <<~XML
            <?xml version="1.0" encoding="utf-8"?>
            <EnumerationResults ServiceEndpoint="https://dummy-account.blob.core.windows.net/" ContainerName="dummy-container">
              <Blobs>
                <Blob>
                  <Name>12345/solicitor.docx</Name>
                  <Properties>
                    <Last-Modified>Mon, 04 Nov 2019 12:30:14 GMT</Last-Modified>
                  </Properties>
                </Blob>
                <Blob>
                  <Name>12345/hmrc_appeal.docx</Name>
                  <Properties>
                    <Last-Modified>Mon, 04 Nov 2019 13:34:37 GMT</Last-Modified>
                  </Properties>
                </Blob>
              </Blobs>
              <NextMarker />
            </EnumerationResults>
          XML
        end

        let(:expected_response) do
          {
            collection: '12345',
            folder: nil,
            files: [
              {
                key: '12345/solicitor.docx',
                title: 'solicitor.docx',
                last_modified: 'Mon, 04 Nov 2019 12:30:14 GMT'
              },
              {
                key: '12345/hmrc_appeal.docx',
                title: 'hmrc_appeal.docx',
                last_modified: 'Mon, 04 Nov 2019 13:34:37 GMT'
              }
            ],
            action: 'List'
          }.to_json
        end

        it 'returns a 200 ok' do
          get '/12345'
          expect(last_response.status).to eq(200)
        end

        it 'returns a list of the files in a collection' do
          get '/12345'
          expect(last_response.body).to eq(expected_response)
        end
      end
    end

    describe 'the collection is empty' do
      let(:blob_storage_response) do
        <<~XML
          <?xml version="1.0" encoding="utf-8"?>
          <EnumerationResults ServiceEndpoint="https://dummy-account.blob.core.windows.net/" ContainerName="empty-container">
            <Blobs />
            <NextMarker />
          </EnumerationResults>
        XML
      end

      let(:expected_response) do
        { errors: ["Collection '12345' does not exist or is empty."] }.to_json
      end

      it 'returns a 404 not found' do
        get '/12345'
        expect(last_response.status).to eq(404)
      end

      it 'returns an error message' do
        get '/12345'
        expect(last_response.body).to eq(expected_response)
      end
    end
  end
end
