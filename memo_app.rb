#!/usr/bin/env ruby

require 'sinatra'
require 'sinatra/reloader'
require 'json'
require 'byebug'

def collect_memo_data
  file_names = Dir.glob("*", base: "./memos")
  @memo_files = []
  file_names.each do |name|
    @memo_files << File.open("./memos/#{name}") do |file|
      JSON.load(file)
    end
  end
end

def sort_by_created_at
  @memo_files = @memo_files.sort do |a, b|
                 a["created_at"] <=> b["created_at"]
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
  sort_by_created_at
  #@memo_files = @memo_files.sort do |a, b|
  #               a["created_at"] <=> b["created_at"]
  #             end
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
  id = SecureRandom.uuid
  @title = params[:memo_title]
  @body = params[:memo_body]
  @created_at = Time.now
  number_of_files = Dir.glob("*", base: "./memos").size
  @latest_number = number_of_files + 1
  File.open("./memos/memo_#{@latest_number}.json", 'w') do |file|
    new_memo_data = JSON.dump({"id" => id, "number" => @latest_number, "title" => @title, "body" => @body, "created_at" => @created_at}, file)
  end
  erb :created 
end

get '/memos/*' do |num|
  collect_memo_data
  sort_by_created_at
  index = num.to_i - 1
  selected_memo = @memo_files[index]
  @selected_number = selected_memo["number"]
  @selected_title = selected_memo["title"]
  @selected_body = selected_memo["body"]
  erb :edit
end

patch '/memos/:file_number' do
  @original_file = File.open("./memos/memo_#{params[:file_number]}") do |file|
    JSON.load(file)
  end
  @original_file["title"] = params[:memo_title]
  @original_file["body"] = params[:memo_body]
  @original_file["edited_at"] = Time.now
  File.open("./memos/memo_#{params[:file_number]}", "w") do |file|
    JSON.dump(@original_file, file)
  end
  erb :edited
end
