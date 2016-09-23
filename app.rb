require 'sinatra'
require 'json'
require_relative 'lib/moj_file'
require 'pry'

module MojFile
  class Uploader < Sinatra::Base
    get '/status' do
      { status: 'OK' }.to_json
    end

    post '/?:collection_ref?/new' do |collection_ref|
      @add = Add.new(collection_ref: collection_ref,
                     params: body_params)

      if @add.valid?
        @add.upload
        status(200)
        body({ collection: @add.collection, key: @add.file_key }.to_json)
      else
        status(422) # Unprocessable entity
        return({ errors: @add.errors }.to_json)
      end
    end

		helpers do
			def body_params
				JSON.parse(request.body.read)
			end
		end
  end
end
