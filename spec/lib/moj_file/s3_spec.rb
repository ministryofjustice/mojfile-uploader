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

    it 'sets up an AWS::S3::Resource with the correct region' do
      expect(Aws::S3::Resource).to receive(:new).with(region: 'eu-west-1')
      object.new.s3
    end
  end

  # These are mutant-kills. See features/healthcheck_spec_s3.rb for operational examples.
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
