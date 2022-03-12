#!/usr/bin/env ruby
# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'byebug'
require 'cgi'
require 'pg'

def make_a_connection_to_db
  host = 'localhost'
  port = 5432
  db = 'memodb'
  user = 'memoapp'
  PG::Connection.new(host: host, port: port, dbname: db, user: user)
end

CONNECTION = make_a_connection_to_db

CONNECTION.prepare('create', 'INSERT INTO memos (title, body, created_at) VALUES ($1, $2, $3)')

CONNECTION.prepare('update', 'UPDATE memos SET title = $1, body = $2, edited_at = $3 WHERE id = $4')

CONNECTION.prepare('delete', 'DELETE FROM memos WHERE id = $1')

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
    all_memo_data = CONNECTION.exec('SELECT * FROM memos ORDER BY created_at DESC').to_a
    all_memo_data.map { |hash| Memo.new(hash) }
  end

  def self.find_a_memo(id)
    memo_data = CONNECTION.exec('SELECT * FROM memos WHERE id = $1', [id]).to_a
    memo = memo_data.map { |hash| Memo.new(hash) }
    memo[0]
  end

  def self.post_a_memo(title_params, body_params, created_at_params)
    CONNECTION.exec_prepared('create', [title_params, body_params, created_at_params])
  end

  def self.edit_a_memo(new_title, new_body, edited_at, id)
    CONNECTION.exec_prepared('update', [new_title, new_body, edited_at, id])
  end

  def self.delete_a_memo(id)
    CONNECTION.exec_prepared('delete', [id])
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
  title = params[:memo_title]
  body = params[:memo_body]
  created_at = Time.now
  Memo.post_a_memo(title, body, created_at)
  redirect '/'
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
  new_title = params[:memo_title]
  new_body = params[:memo_body]
  edited_at = Time.now
  Memo.edit_a_memo(new_title, new_body, edited_at, id)
  redirect '/'
end

delete '/memos/:id' do |id|
  Memo.delete_a_memo(id)
  redirect '/'
end

not_found do
  'このページは存在しません'
end
