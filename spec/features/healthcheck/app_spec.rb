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
    allow(MojFile::Scan).to receive(:healthcheck_infected).and_return(true)
    allow(MojFile::Scan).to receive(:healthcheck_clean).and_return(true)
    stub_request(:put, /healthcheck\.docx/).to_return(status: 200)
    get '/healthcheck'
  end

  describe 'happy path' do
    it 'reports that the service is ok' do
      expect(service_status).to eq('ok')
    end
  end
end
