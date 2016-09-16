require_relative '../spec_helper'

RSpec.describe 'Status' do
  it 'reports stats as OK' do
    get '/status'
    expect(last_response.body).to eq( { status: 'OK' }.to_json )
  end
end
