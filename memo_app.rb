#!/usr/bin/env ruby

require 'sinatra'
require 'sinatra/reloader'
require 'json'

get '/' do
  erb :top
end

get '/new' do
  erb :new
end

post '/memos' do
  @id = SecureRandom.uuid
  @title = params[:memo_title]
  @body = params[:memo_body]
  @created_at = Time.now
  File.open("./memos/memo_#{@id}.json", 'w') do |file|
    new_memo_data = JSON.dump({"title" => @title, "body" => @body, "created_at" => @created_at}, file)
  end
  erb :created 
end

