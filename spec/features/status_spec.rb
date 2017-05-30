require_relative '../spec_helper'

RSpec.describe 'Parsed status response' do
  let(:resp) { JSON.parse(last_response.body, symbolize_names: true) }

  let(:av) { resp[:dependencies][:external][:av] }
  let(:s3) { resp[:dependencies][:external][:s3] }

  before do
    allow(MojFile::Add).to receive(:write_test)
    allow(MojFile::Scan).to receive(:statuscheck_clean)
    allow(MojFile::Scan).to receive(:statuscheck_infected)
    allow_any_instance_of(MojFile::Uploader).to receive(:`).and_return('ABC123')
  end

  context 'version' do
    specify do
      get '/status'
      expect(resp).to include(version: 'ABC123')
    end
  end

  context 'when EICAR test succeeds' do
    subject { av[:dependencies][:external][:av] }
    specify do
      expect(MojFile::Scan).to receive(:statuscheck_infected).and_return(true)
      get '/status'
      expect(av).to include(detected_infected_file: 'ok')
    end
  end

  context 'when EICAR test fails' do
    before do
      expect(MojFile::Scan).to receive(:statuscheck_infected).and_return(false)
      get '/status'
    end

    specify do
      expect(resp).to include(service_status: 'failed')
    end

    specify do
      expect(av).to include(detected_infected_file: 'failed')
    end
  end

  context 'when clean file test succeeds' do
    specify do
      expect(MojFile::Scan).to receive(:statuscheck_clean).and_return(true)
      get '/status'
      expect(av).to include(passed_clean_file: 'ok')
    end
  end

  context 'when clean file test fails' do
    before do
      expect(MojFile::Scan).to receive(:statuscheck_clean).and_return(false)
      get '/status'
    end

    specify do
      expect(resp).to include(service_status: 'failed')
    end

    specify do
      expect(av).to include(passed_clean_file: 'failed')
    end
  end

  context 'when write test succeeds' do
    specify do
      expect(MojFile::Add).to receive(:write_test).and_return(true)
      get '/status'
      expect(s3).to include(write_test: 'ok')
    end
  end

  context 'when write test fails' do
    before do
      expect(MojFile::Add).to receive(:write_test).and_return(false)
      get '/status'
    end

    specify do
      expect(resp).to include(service_status: 'failed')
    end

    specify do
      expect(s3).to include(write_test: 'failed')
    end
  end
end
