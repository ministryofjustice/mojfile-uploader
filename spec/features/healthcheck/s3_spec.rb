require_relative '../../spec_helper'

RSpec.describe 'Healthcheck' do
  let(:dependencies) {
    JSON.parse(
      last_response.body,
      symbolize_names: true
    )[:dependencies]
  }

  before do
    allow(MojFile::Scan).to receive(:trigger_alert)
    allow(MojFile::Scan).to receive(:clean_file)
  end

  context 'AWS status endpoint' do
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

    # Many of the tags have been removed for brevity.
    let(:failed_response) {
      <<-XML
            <?xml version="1.0" encoding="UTF-8"?>
            <rss version="2.0">
              <channel>
              </channel>
            </rss>
      XML
    }

    describe 'default region [:external][:s3][:eu_west_1]' do
      before do
        stub_request(:get, "https://status.aws.amazon.com/rss/s3-eu-west-1.rss").
          to_return(status: 200, body: status_response)
      end

      describe 'if the endpoint reports that the service is working, the key' do
        specify do
          get '/healthcheck'
          expect(dependencies[:external][:s3][:eu_west_1]).
            to eq('Service is operating normally')
        end
      end

      describe 'if the endpoint does not reply the key' do
        before do
          stub_request(:get, "https://status.aws.amazon.com/rss/s3-eu-west-1.rss").
            to_return(status: 200, body: failed_response)
        end

        specify do
          get '/healthcheck'
          expect(dependencies[:external][:s3][:eu_west_1]).
            to eq('N/A')
        end
      end
    end

    describe 'different region [:external][:s3][:us_east_1]' do
      before do
        stub_const('MojFile::S3::REGION', 'us-east-1')
        # The stubbed constants do not propogate for some unclear reason.
        stub_const('MojFile::S3::STATUS_RSS_ENDPOINT', 'https://status.aws.amazon.com/rss/s3-us-east-1.rss')

        stub_request(:get, "https://status.aws.amazon.com/rss/s3-us-east-1.rss").
          to_return(status: 200, body: status_response)
      end

      describe 'if the endpoint reports that the service is working, the key' do
        specify do
          get '/healthcheck'
          expect(dependencies[:external][:s3][:us_east_1]).
            to eq('Service is operating normally')
        end
      end

      describe 'if the endpoint does not reply the key' do
        before do
          stub_request(:get, "https://status.aws.amazon.com/rss/s3-us-east-1.rss").
            to_return(status: 200, body: failed_response)
        end

        specify do
          get '/healthcheck'
          expect(dependencies[:external][:s3][:us_east_1]).
            to eq('N/A')
        end
      end
    end
  end
end
