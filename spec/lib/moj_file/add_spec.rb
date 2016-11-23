require 'spec_helper'

RSpec.describe MojFile::Add do
  let(:params) {
    {
      'file_title' => 'Test Upload',
      'file_filename' => 'testfile.docx',
      'file_data' =>  Base64.encode64('Encoded document body')
    }
  }

  describe '#scan_clear?' do
    before do
      scan = instance_double(MojFile::Scan)
      expect(scan).to receive(:scan_clear?)
      expect(MojFile::Scan).to receive(:new).
        with(filename: params['file_filename'], data: params['file_data']).
        and_return(scan)
    end

    it 'calls MojFile::Scan' do
      described_class.new(collection_ref: nil, params: params).scan_clear?
    end
  end
end
