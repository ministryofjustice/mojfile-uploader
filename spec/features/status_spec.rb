require_relative '../spec_helper'

RSpec.feature 'Status' do
  it 'reports stats as OK' do
    visit '/status'
    expect(page.body).to eq( { status: 'OK' }.to_json )
  end
end
