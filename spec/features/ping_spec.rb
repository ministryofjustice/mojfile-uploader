require_relative '../spec_helper'

RSpec.describe 'Ping response' do
  describe 'status' do
    specify do
      get '/ping'
      expect(last_response.status).to be 200
    end
  end
end
