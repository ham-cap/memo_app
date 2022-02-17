#!/usr/bin/env ruby
# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'json'
require 'byebug'
require 'cgi'
require 'pg'

def make_a_connection_to_db
  host = 'localhost'
  port = 5432
  db = 'postgres'
  user = 'postgres'
  @connection = PG::Connection.new(host: host, port: port, dbname: db, user: user)
end

class Memo
  attr_reader :id, :title, :body, :created_at, :edited_at

  def initialize(hash)
    @id = hash['id']
    @title = hash['title']
    @body = hash['body']
    @created_at = hash['created_at']
    @edited_at = hash['edited_at']
  end

  def self.create_a_memo_array
    make_a_connection_to_db
    all_memo_data = @connection.exec('SELECT * FROM memos').to_a
    all_memo_data.map { |hash| Memo.new(hash) }.reverse
  end

  def self.find_a_memo(id)
    make_a_connection_to_db
    memo_data = @connection.exec('SELECT * FROM memos WHERE id = $1', [id]).to_a
    memo = memo_data.map { |hash| Memo.new(hash) }
    memo[0]
  end
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
  make_a_connection_to_db
  @connection.prepare('create', 'INSERT INTO memos (title, body, created_at) VALUES ($1, $2, $3)')
  @connection.exec_prepared('create', [@title, @body, @created_at])
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
  @new_title = params[:memo_title]
  @new_body = params[:memo_body]
  @edited_at = Time.now
  make_a_connection_to_db
  @connection.prepare('update', 'UPDATE memos SET title = $1, body = $2, edited_at = $3 WHERE id = $4')
  @connection.exec_prepared('update', [@new_title, @new_body, @edited_at, @id])
  erb :edited
end

delete '/memos/:id' do |id|
  make_a_connection_to_db
  @connection.prepare('delete', 'DELETE from memos WHERE id = $1')
  @connection.exec_prepared('delete', [id])
  erb :deleted
end

not_found do
  'このページは存在しません'
end
