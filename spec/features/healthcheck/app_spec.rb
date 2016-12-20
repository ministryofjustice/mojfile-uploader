require_relative '../../spec_helper'

RSpec.describe 'Service status' do
  let(:service_status) {
    JSON.parse(
      last_response.body,
      symbolize_names: true
    )[:service_status]
  }

  before do
    allow(MojFile::S3).to receive(:status)
    get '/healthcheck'
  end

  describe 'happy path' do
    it 'reports that the service is OK' do
      expect(service_status).to eq('OK')
    end
  end
end
