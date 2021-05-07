# frozen_string_literal: true

require 'spec_helper'

RSpec.describe MojFile::Scan do
  let(:params) do
    {
      filename: 'testfile.docx',
      data: Base64.encode64('Encoded document body')
    }
  end

  let!(:rest_client_stub) do
    allow(RestClient).to receive(:post)
  end

  let(:clean_result) { "true\n" }
  let(:infected_result) { "false\n" }

  let(:resp) { instance_double(RestClient::Response, body: clean_result) }
  let(:infected) { instance_double(RestClient::Response, body: infected_result) }

  describe '.initialize' do
    subject { described_class.new(filename: params[:filename], data: params[:data]) }

    specify '#logger is set to DummyLogger by default' do
      expect(subject.logger).to be_a_kind_of(DummyLogger)
    end
  end

  describe '.statuscheck_clean' do
    it 'sends a simple file name to aid identifying these calls in the logs' do
      expect(described_class)
        .to receive(:new)
        .with(hash_including(filename: 'clean test')).and_return(
          instance_double(described_class, scan_clear?: true)
        )
      described_class.statuscheck_clean
    end

    it 'reports OK' do
      allow(RestClient).to receive(:post).and_return(resp)
      expect(described_class.statuscheck_clean).to be_truthy
    end

    # It always uses the same test string, so this should not fail if the
    # scanner is working correctly.
    it 'reports FAILED' do
      allow(RestClient).to receive(:post).and_return(infected)
      expect(described_class.statuscheck_clean).to be_falsey
    end
  end

  describe '.statuscheck_infected' do
    it 'sends a simple file name to aid identifying these calls in the logs' do
      expect(described_class)
        .to receive(:new)
        .with(hash_including(filename: 'eicar test')).and_return(
          instance_double(described_class, scan_clear?: false)
        )
      described_class.statuscheck_infected
    end

    it 'reports true' do
      allow(RestClient).to receive(:post).and_return(infected)
      expect(described_class.statuscheck_infected).to be_truthy
    end

    # It always uses the same test string, so this should not fail if the
    # scanner is working correctly.
    it 'reports false' do
      allow(RestClient).to receive(:post).and_return(resp)
      expect(described_class.statuscheck_infected).to be_falsey
    end
  end

  describe '#scan_clear?' do
    before do
      allow(RestClient).to receive(:post).and_return(resp)
    end

    context 'clear' do
      before do
        expect(resp).to receive(:body).and_return(clean_result)
      end

      it 'returns true' do
        expect(
          described_class
          .new(filename: params[:filename], data: params[:data]).scan_clear?
        ).to be_truthy
      end
    end

    context 'infected' do
      before do
        expect(resp).to receive(:body).and_return(infected_result)
      end

      it 'returns false' do
        expect(
          described_class
          .new(filename: params[:filename], data: params[:data]).scan_clear?
        ).to be_falsey
      end
    end

    context 'errors' do
      subject { described_class.new(filename: params[:filename], data: params[:data]) }
      let(:resp) { instance_double(RestClient::Response, body: nil) }
      let(:logger) { double.as_null_object }

      before do
        subject.logger = logger
      end

      it 'catches and re-raises mangled response errors' do
        expect(logger).to receive(:error).with(hash_including(error: /NoMethodError/, backtrace: a_kind_of(Array)))
        expect { subject.scan_clear? }.to raise_error(NoMethodError)
      end
    end

    context 'RestClient' do
      subject(:scan_file) do
        described_class.new(filename: params[:filename], data: params[:data])
                       .scan_clear?
      end

      let(:rest_client_called) { expect(RestClient).to receive(:post) }
      let(:scanner_url) { 'http://my-test-scanner' }

      before do
        allow(ENV).to receive(:fetch).with('SCANNER_URL', 'http://clamav-rest:8080/scan').and_return(scanner_url)
      end

      it 'is called with the correct endpoint' do
        rest_client_called.with('http://my-test-scanner', anything)
                          .and_return(resp)
        scan_file
      end

      it 'is called with the filename' do
        rest_client_called
          .with(anything, hash_including(name: params[:filename]))
          .and_return(resp)
        scan_file
      end

      it 'is called with the data/content of the file' do
        rest_client_called
          .with(anything, hash_including(file: instance_of(MojFile::DummyPath)))
          .and_return(resp)
        scan_file
      end

      it 'uses multipart' do
        rest_client_called
          .with(anything, hash_including(multipart: true))
          .and_return(resp)
        scan_file
      end

      it 'captures the response body from the post' do
        expect(resp).to receive(:body).and_return(clean_result)
        rest_client_called.and_return(resp)
        scan_file
      end
    end
  end

  context 'DummyPath' do
    # RestClient won’t do multipart unless it thinks it is dealing with a
    # filesystem object.  DummyPath is a simple way of making it work by
    # associating a path with the StringIo object.
    it 'sets up a dummy filename for multipart' do
      expect(MojFile::DummyPath).to receive(:new).with(params[:data])
      described_class.new(filename: params[:filename], data: params[:data])
    end
  end
end
