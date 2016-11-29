require 'spec_helper'

RSpec.describe MojFile::S3 do
  let(:object) {
    Class.new do
      include MojFile::S3
    end
  }

  it 'adds an s3 resource to the class' do
    allow(ENV).to receive(:fetch).with('AWS_REGION', 'eu-west-1').and_return('eu-west-1')
    expect(object.new.s3).to be_an_instance_of(Aws::S3::Resource)
  end

  it 'fetches the access key from the ENV' do
    allow(ENV).to receive(:fetch).with('AWS_REGION', 'eu-west-1').and_return('eu-west-1')
    object.new.s3
  end

  it 'fetches the secret access key from the ENV' do
    allow(ENV).to receive(:fetch).with('AWS_REGION', 'eu-west-1').and_return('eu-west-1')
    object.new.s3
  end

  it 'fetches the region from the ENV and has a default' do
    expect(ENV).to receive(:fetch).with('AWS_REGION', 'eu-west-1').and_return('eu-west-1')
    object.new.s3
  end
end
