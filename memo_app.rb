#!/usr/bin/env ruby
# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'json'
require 'byebug'
require 'cgi'

def collect_memo_data
  file_names = Dir.glob('*', base: './memos')
  @memo_files = file_names.map do |name|
    File.open("./memos/#{name}") do |file|
      read_line = file.read
      JSON.parse(read_line)
    end
  end
end

def sort_by_created_at
  @memo_files = @memo_files.sort_by { |a| a['created_at'] }
end

def reverse_memos_order
  @memo_files = @memo_files.reverse
end

def find_selected_memo(number)
  index = number.to_i - 1
  @selected_memo = @memo_files[index]
end

get '/' do
  collect_memo_data
  sort_by_created_at
  reverse_memos_order
  @memo_titles = []
  @memo_files.each do |memo|
    @memo_titles << memo['title']
  end
  erb :top
end

get '/new' do
  erb :new
end

post '/memos' do
  id = SecureRandom.uuid
  @title = CGI.escapeHTML(params[:memo_title])
  @body = CGI.escapeHTML(params[:memo_body])
  @created_at = Time.now
  number_of_files = Dir.glob('*', base: './memos').size
  @latest_number = number_of_files + 1
  File.open("./memos/memo_#{@latest_number}.json", 'w') do |file|
    JSON.dump({ 'id' => id, 'number' => @latest_number, 'title' => @title, 'body' => @body, 'created_at' => @created_at }, file)
  end
  erb :created
end

get '/memos/show/:number' do |number|
  collect_memo_data
  sort_by_created_at
  find_selected_memo(number)
  erb :show
end

get '/memos/edit/:number' do |number|
  collect_memo_data
  sort_by_created_at
  find_selected_memo(number)
  erb :edit
end

patch '/memos/:file_number' do
  @original_file = File.open("./memos/memo_#{params[:file_number]}.json") do |file|
    read_line = file.read
    JSON.parse(read_line)
  end
  @original_file['title'] = CGI.escapeHTML(params[:memo_title])
  @original_file['body'] = CGI.escapeHTML(params[:memo_body])
  @original_file['edited_at'] = Time.now
  File.open("./memos/memo_#{params[:file_number]}.json", 'w') do |file|
    JSON.dump(@original_file, file)
  end
  erb :edited
end

delete '/memos/:number' do |n|
  File.delete("./memos/memo_#{n}")
  erb :deleted
end
