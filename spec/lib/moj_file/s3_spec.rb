require 'spec_helper'

RSpec.describe MojFile::S3 do
  let(:object) {
    Class.new do
      include MojFile::S3
    end
  }

  it 'adds an s3 resource to the class' do
    allow(ENV).to receive(:fetch).with('AWS_REGION', 'eu-west-1').and_return('eu-west-1')
    expect(object.new.s3).to be_an_instance_of(Aws::S3::Resource)
  end

  it 'fetches the access key from the ENV' do
    allow(ENV).to receive(:fetch).with('AWS_REGION', 'eu-west-1').and_return('eu-west-1')
    object.new.s3
  end

  it 'fetches the secret access key from the ENV' do
    allow(ENV).to receive(:fetch).with('AWS_REGION', 'eu-west-1').and_return('eu-west-1')
    object.new.s3
  end

  describe '#s3' do
    let(:resource) { instance_double(Aws::S3::Resource) }
    let(:client) { instance_double(Aws::S3::Client) }

    before do
      allow(Aws::S3::Client).to receive(:new).and_return(client)
      allow(Aws::S3::Resource).to receive(:new).and_return(resource)
      object.new.s3
    end

    context 'Aws::S3::Client' do
      it 'sets the region' do
        expect(Aws::S3::Client).to have_received(:new).with(hash_including({region: 'eu-west-1'}))
      end

      it 'increases the number of retries over default (3)' do
        expect(Aws::S3::Client).to have_received(:new).with(hash_including({retry_limit: MojFile::S3::RETRY_LIMIT}))
      end

      it 'only compute checksums for operations that require them' do
        # http://docs.aws.amazon.com/sdkforruby/api/Aws/S3/Client.html#initialize-instance_method
        expect(Aws::S3::Client).to have_received(:new).with(hash_including({compute_checksums: false}))
      end
    end

    context 'Aws::S3::Resource' do
      it 'is exposed by the #s3 method' do
        expect(object.new.s3).to eq(resource)
      end

      it 'uses the configured Aws::S3::Client' do
        expect(Aws::S3::Resource).to have_received(:new).with(client: client)
      end
    end
  end

  describe '#object' do
    let(:s3_bucket) { double('Bucket', object: 'whatever') }
    subject { object.new }

    before do
      expect(ENV).to receive(:fetch).with('BUCKET_NAME').and_return('bucket-name')
      allow(subject).to receive_message_chain(:s3, :bucket).and_return(s3_bucket)
    end

    context 'retrieving objects from a folder' do
      let(:object) {
        Class.new do
          include MojFile::S3

          def collection; 'collection'; end
          def folder; 'folder'; end
          def filename; 'test.doc'; end
        end
      }

      it 'should retrieve the s3 object from the correct bucket' do
        expect(s3_bucket).to receive(:object).with('collection/folder/test.doc')
        subject.object
      end
    end

    context 'retrieving objects when no folder provided' do
      let(:object) {
        Class.new do
          include MojFile::S3

          def collection; 'collection'; end
          def folder; nil; end
          def filename; 'test.doc'; end
        end
      }

      it 'should retrieve the s3 object from the correct bucket' do
        expect(s3_bucket).to receive(:object).with('collection/test.doc')
        subject.object
      end
    end
  end

  # These are mutant-kills. See features/status_spec_s3.rb for operational examples.
  describe '.status' do
    let(:status_response) {
      <<-XML
      <?xml version="1.0" encoding="UTF-8"?>
      <rss version="2.0">
        <channel>
         <item>
          <title type="text">Service is operating normally</title>
          <pubDate>Wed,  9 May 2012 12:54:00 PDT</pubDate>
         </item>

         <item>
          <title type="text">Increased error rates in Amazon S3</title>
          <pubDate>Wed,  9 May 2012 12:37:00 PDT</pubDate>
         </item>
        </channel>
      </rss>
      XML
    }

    it 'calls the AWS endpoint' do
      expect(RestClient).to receive(:get).with(described_class::STATUS_RSS_ENDPOINT)
      described_class.status
    end

    it 'parses the response' do
      allow(RestClient).to receive(:get).and_return(double('response', body: status_response))
      expect(Nokogiri).to receive(:parse)
      described_class.status
    end

    it 'returns the most current item' do
      allow(RestClient).to receive(:get).and_return(double('response', body: status_response))
      expect(described_class.status).to eq('Service is operating normally')
    end

    # This would be the error if the xpath didn't exist.
    it 'returns N/A if Nokogiri raises a NoMethodError' do
      allow(RestClient).to receive(:get).and_return(double('response', body: ''))
      expect(described_class.status).to eq('N/A')
    end
  end
end
