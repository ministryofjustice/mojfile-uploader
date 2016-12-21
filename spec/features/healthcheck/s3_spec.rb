require_relative '../../spec_helper'

RSpec.describe 'Healthcheck' do
  let(:dependencies) {
    JSON.parse(
      last_response.body,
      symbolize_names: true
    )[:dependencies]
  }

  # Many of the tags have been removed for brevity.
  # It is overridden as needed.
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

  before do
    allow(MojFile::Scan).to receive(:trigger_alert)
    allow(MojFile::Scan).to receive(:clean_file)
  end

  describe 'happy path' do
    before do
      stub_request(:get, "https://status.aws.amazon.com/rss/s3-eu-west-1.rss").
        to_return(status: 200, body: status_response)
    end

    it 'reports the first status from the list for S3 eu-west-1' do
      get '/healthcheck'
      expect(dependencies[:external][:s3][:eu_west_1]).
        to eq('Service is operating normally')
    end
  end

  describe 'no info' do
    # Many of the tags have been removed for brevity.
    let(:status_response) {
      <<-XML
      <?xml version="1.0" encoding="UTF-8"?>
      <rss version="2.0">
        <channel>
        </channel>
      </rss>
      XML
    }

    before do
      stub_request(:get, "https://status.aws.amazon.com/rss/s3-eu-west-1.rss").
        to_return(status: 200, body: status_response)
    end

    it 'returns N/A' do
      get '/healthcheck'
      expect(dependencies[:external][:s3][:eu_west_1]).
        to eq('N/A')
    end
  end

  describe 'different regions' do
    before do
      stub_const('MojFile::S3::REGION', 'us-east-1')
      # The stubbed constants do not propogate for some unclear reason.
      stub_const('MojFile::S3::STATUS_RSS_ENDPOINT', 'https://status.aws.amazon.com/rss/s3-us-east-1.rss')

      stub_request(:get, "https://status.aws.amazon.com/rss/s3-us-east-1.rss").
        to_return(status: 200, body: status_response)
    end

    it 'reports the first status from the list for S3 us-east-1' do
      get '/healthcheck'
      expect(dependencies[:external][:s3][:us_east_1]).
        to eq('Service is operating normally')
    end
  end
end
