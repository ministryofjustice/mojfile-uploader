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
  end

  describe 'happy path' do
    describe 'detects a virus' do
      before do
        expect(RestClient).to receive(:post).twice.and_return(double('response', body: ''))
      end

      specify do
        get '/healthcheck'
        expect(av[:detect_infection]).to eq('OK')
      end
    end

    describe 'fails when it should have detected a virus' do
      before do
        expect(RestClient).to receive(:post).twice.and_return(double('response', body: 'true'))
      end

      specify do
        get '/healthcheck'
        expect(av[:detect_infection]).to eq('FAILED')
      end
    end

    describe 'passes a clean file' do
      before do
        expect(RestClient).to receive(:post).twice.and_return(double('response', body: 'true'))
      end

      specify do
        get '/healthcheck'
        expect(av[:pass_clean]).to eq('OK')
      end
    end

    describe 'fails when it should have passed a clean file' do
      before do
        expect(RestClient).to receive(:post).twice.and_return(double('response', body: ''))
      end

      specify do
        get '/healthcheck'
        expect(av[:pass_clean]).to eq('FAILED')
      end
    end
  end
end
