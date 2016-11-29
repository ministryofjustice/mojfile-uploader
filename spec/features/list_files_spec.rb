require_relative '../spec_helper'

RSpec.describe MojFile::List do
  let!(:s3_stub) {
    stub_request(:get, /uploader-test-bucket.+amazonaws\.com\/\?encoding-type=url&prefix=12345/).
    to_return(body: aws_response, status: 200)
  }

  context 'happy paths' do
    describe 'the collection has files' do
      let(:aws_response) {
        <<-XML
<?xml version="1.0" encoding="UTF-8"?>
<ListBucketResult xmlns="http://s3.amazonaws.com/doc/2006-03-01/">
    <Name>bucket</Name>
    <KeyCount>2</KeyCount>
    <Contents>
        <Key>12345/solicitor.docx</Key>
        <LastModified>2016-10-12T17:50:30.000Z</LastModified>
    </Contents>
    <Contents>
        <Key>12345/hmrc_appeal.docx</Key>
        <LastModified>2016-10-12T17:50:30.000Z</LastModified>
    </Contents>
</ListBucketResult>
        XML
      }

      let(:expected_response) {
        {
          collection: '12345',
          files: [
            {
              key: '12345/solicitor.docx',
              title: 'solicitor.docx',
              last_modified: '2016-10-12T17:50:30.000Z'
            },
            {
              key: '12345/hmrc_appeal.docx',
              title: 'hmrc_appeal.docx',
              last_modified: '2016-10-12T17:50:30.000Z'
            }
        ]
        }.to_json
      }


      it 'returns a 200 ok' do
        get '/12345'
        expect(last_response.status).to eq(200)
      end

      it 'returns a list of the files in a collection' do
        get '/12345'
        expect(last_response.body).to eq(expected_response)
      end
    end

    describe 'the collection is empty' do
      let(:aws_response) {
        <<-XML
<?xml version="1.0" encoding="UTF-8"?>
<ListBucketResult xmlns="http://s3.amazonaws.com/doc/2006-03-01/">
    <Name>bucket</Name>
    <KeyCount>0</KeyCount>
</ListBucketResult>
        XML
      }

      let(:expected_response) {
        { errors: ["Collection '12345' does not exist or is empty."] }.to_json
      }

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
