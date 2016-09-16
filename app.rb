require 'sinatra'
require 'json'

class MoJFileUploader < Sinatra::Base
  get '/status' do
    { status: 'OK' }.to_json
  end
end
