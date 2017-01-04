require_relative '../../spec_helper'

RSpec.describe 'Healthcheck' do
  let(:av) {
    JSON.parse(
      last_response.body,
      symbolize_names: true
    )[:dependencies][:external][:av]
  }

  before do
    allow(MojFile::S3).to receive(:status)
    stub_request(:put, /healthcheck\.docx/).to_return(status: 200)
  end

  describe 'happy path' do
    describe 'detects a virus' do
      before do
        expect(RestClient).to receive(:post).twice.and_return(double('response', body: ''))
      end

      specify do
        get '/healthcheck'
        expect(av[:detected_infected_file]).to eq('ok')
      end
    end

    describe 'fails when it should have detected a virus' do
      before do
        expect(RestClient).
          to receive(:post).
          twice.
          and_return(double('response', body: MojFile::Scan::EXPECTED_CLEAR_RESPONSE))
      end

      specify do
        get '/healthcheck'
        expect(av[:detected_infected_file]).to eq('failed')
      end
    end

    describe 'passes a clean file' do
      before do
        expect(RestClient).
          to receive(:post).
          twice.
          and_return(double('response', body: MojFile::Scan::EXPECTED_CLEAR_RESPONSE))
      end

      specify do
        get '/healthcheck'
        expect(av[:passed_clean_file]).to eq('ok')
      end
    end

    describe 'fails when it should have passed a clean file' do
      before do
        expect(RestClient).
          to receive(:post).
          twice.
          and_return(double('response', body: ''))
      end

      specify do
        get '/healthcheck'
        expect(av[:passed_clean_file]).to eq('failed')
      end
    end
  end
end
