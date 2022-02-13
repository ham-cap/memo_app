#!/usr/bin/env ruby
# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'json'
require 'byebug'
require 'cgi'
require 'pg'

def make_a_connection
  host = '133.167.114.88'
  port = 5432
  db = 'memodb'
  user = 'postgres'
  password = 'm4GxZjes'
  @connection = PG::Connection.new(host: host, port: port, dbname: db, user: user, password: password)
end

class Memo
  attr_reader :id, :title, :body, :created_at, :edited_at

  def initialize(hash)
    @id = hash["id"]
    @title = hash["title"]
    @body = hash["body"]
    @created_at = hash["created_at"]
    @edited_at = hash["edited_at"]
  end
  
  def self.create_a_memo_array
    make_a_connection
    all_memo_data = @connection.exec("SELECT * FROM memos").to_a
    all_memo_data.map{|hash| Memo.new(hash)}.reverse
  end

  def self.find_a_memo(id)
    make_a_connection
    memo_data = @connection.exec("SELECT * FROM memos WHERE id = #{id}").to_a
    memo = memo_data.map{|hash| Memo.new(hash)}
    memo[0]
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
  @memo_array = Memo.create_a_memo_array
  erb :top
end

get '/new' do
  erb :new
end

post '/memos' do
  @title = params[:memo_title]
  @body = params[:memo_body]
  @created_at = Time.now
  make_a_connection
  @connection.exec("INSERT INTO memos (title, body, created_at) VALUES ('#{@title}', '#{@body}', '#{@created_at}')")
  erb :created
end

get '/memos/:id' do |id|
  @selected_memo = Memo.find_a_memo(id)
  erb :show
end

get '/memos/:id/edit' do |id|
  @selected_memo = Memo.find_a_memo(id)
  erb :edit
end

patch '/memos/:id' do |id|
  @id = id
  @inputed_title = params[:memo_title]
  @inputed_body = params[:memo_body]
  make_a_connection
  @connection.exec("UPDATE memos SET title = '#{@inputed_title}', body = '#{@inputed_body}' WHERE id = '#{@id}'")
  erb :edited
end

delete '/memos/:id' do |id|
  make_a_connection
  @connection.exec("DELETE from memos WHERE id = '#{id}'")
  erb :deleted
end

