require_relative '../../spec_helper'

RSpec.describe 'Healthcheck' do
  let(:parsed_response) {
    JSON.parse(
      last_response.body,
      symbolize_names: true
    )
  }

  let(:s3_subkey) {
    parsed_response[:dependencies][:external][:s3]
  }

  before do
    allow(MojFile::Scan).to receive(:healthcheck_infected)
    allow(MojFile::Scan).to receive(:healthcheck_clean)
  end

  context 'Successful write test' do
    let(:decoded_file_data) { 'A document body' }
    let!(:write_stub) {
      stub_request(:put, /healthcheck\.docx/).
      with(body: decoded_file_data).
      to_return(status: 200)
    }

    before do
      stub_request(:get, 'https://status.aws.amazon.com/rss/s3-eu-west-1.rss')
    end

    describe '[:external][:s3][:write_test]' do
      specify do
        get '/healthcheck'
        expect(s3_subkey[:write_test]).to eq('ok')
      end
    end

    describe '[:service_status]' do
      before do
        allow(MojFile::S3).to receive(:status)
        allow(MojFile::Scan).to receive(:healthcheck_infected).and_return(true)
        allow(MojFile::Scan).to receive(:healthcheck_clean).and_return(true)
      end

      specify do
        get '/healthcheck'
        expect(parsed_response[:service_status]).to eq('ok')
      end
    end
  end

  context 'Failed write test' do
    let(:decoded_file_data) { 'A document body' }
    let!(:write_stub) {
      stub_request(:put, /healthcheck\.docx/).
      with(body: decoded_file_data).
      to_return(status: 422)
    }

    before do
      stub_request(:get, 'https://status.aws.amazon.com/rss/s3-eu-west-1.rss')
    end

    describe '[:external][:s3][:write_test]' do
      specify do
        get '/healthcheck'
        expect(s3_subkey[:write_test]).to eq('failed')
      end
    end

    describe '[:service_status]' do
      specify do
        get '/healthcheck'
        expect(parsed_response[:service_status]).to eq('failed')
      end
    end
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

    before do
      stub_request(:put, /healthcheck\.docx/).to_return(status: 200)
    end

    describe 'default region [:external][:s3][:eu_west_1]' do
      before do
        stub_request(:get, "https://status.aws.amazon.com/rss/s3-eu-west-1.rss").
          to_return(status: 200, body: status_response)
      end

      describe 'if the endpoint reports that the service is working, the key' do
        specify do
          get '/healthcheck'
          expect(s3_subkey[:eu_west_1]).
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
          expect(s3_subkey[:eu_west_1]).to eq('N/A')
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
          expect(s3_subkey[:us_east_1]).
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
          expect(s3_subkey[:us_east_1]).to eq('N/A')
        end
      end
    end
  end
end
