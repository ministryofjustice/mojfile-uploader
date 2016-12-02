require 'spec_helper'

RSpec.describe MojFile::Add do
  let(:encoded_file_data) { 'QSBkb2N1bWVudCBib2R5\n' }
  let(:decoded_file_data) { 'A document body' }

  let(:params) {
    {
      'file_title' => 'Test Upload',
      'file_filename' => 'testfile.docx',
      'file_data' => encoded_file_data
    }
  }

  describe '#scan_clear?' do
    before do
      scan = instance_double(MojFile::Scan)
      expect(scan).to receive(:scan_clear?)
      expect(MojFile::Scan).to receive(:new).
        with(filename: params['file_filename'], data: decoded_file_data).
        and_return(scan)
    end

    it 'calls MojFile::Scan' do
      described_class.new(collection_ref: nil, params: params).scan_clear?
    end
  end
end
