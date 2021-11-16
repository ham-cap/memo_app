#!/usr/bin/env ruby

require 'sinatra'
require 'sinatra/reloader'
require 'json'

def collect_memo_data
  file_names = Dir.glob("*", base: "./memos")
  @memo_files = []
  file_names.each do |name|
    @memo_files << File.open("./memos/#{name}") do |file|
      JSON.load(file)
    end
  end
end

get '/' do
  collect_memo_data
  #file_names = Dir.glob("*", base: "./memos")
  #memo_files = []
  #file_names.each do |name|
  #  memo_files << File.open("./memos/#{name}") do |file|
  #    JSON.load(file)
  #  end
  #end
  @memo_files = @memo_files.sort do |a, b|
                 a["created_at"] <=> b["created_at"]
               end
  @memo_files = @memo_files.reverse
  @memo_titles = []
  @memo_files.each do |memo|
    @memo_titles << memo["title"]
  end
  #@memo_titles.sort
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

