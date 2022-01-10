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
  collect_memo_data
  @selected_memo = @memo_files.find { |file| file['number'] == number.to_i }
end

get '/' do
  collect_memo_data
  sort_by_created_at
  reverse_memos_order
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
  File.open('used_number.txt', 'r') do |file|
    @original_array= file.readlines.map(&:to_i)
  end
  File.open('used_number.txt', 'w') do |file|
    if @original_array.empty?
      @latest_number = 1
      file.puts(@latest_number)
    else
      @latest_number = @original_array.max + 1
      file.puts(@latest_number)
    end
  end
  File.open("./memos/#{id}.json", 'w') do |file|
    JSON.dump({ id: id, number: @latest_number, title: @title, body: @body, created_at: @created_at }, file)
  end
  erb :created
end

get '/memos/:number' do |number|
  collect_memo_data
  sort_by_created_at
  find_selected_memo(number)
  erb :show
end

get '/memos/:number/edit' do |number|
  collect_memo_data
  sort_by_created_at
  find_selected_memo(number)
  erb :edit
end

patch '/memos/:file_number' do
  find_selected_memo(params[:file_number])
  @original_file = File.open("./memos/#{@selected_memo['id']}.json") do |file|
    read_line = file.read
    JSON.parse(read_line)
  end
  @original_file['title'] = params[:memo_title]
  @original_file['body'] = params[:memo_body]
  @original_file['edited_at'] = Time.now
  File.open("./memos/#{@selected_memo['id']}.json", 'w') do |file|
    JSON.dump(@original_file, file)
  end
  erb :edited
end

delete '/memos/:number' do |_n|
  find_selected_memo(params[:number])
  File.delete("./memos/#{@selected_memo['id']}.json")
  erb :deleted
end
