require 'sinatra'
require 'sinatra/reloader' if development?
require 'json'
require "./ChatBoard.rb"

$threadManager = ChatBoard::ChatThreadManager.new

configure :development do
  register Sinatra::Reloader
end

get "/reset" do
  $threadManager.chatThreads.clear
  redirect "/index"
end

get "/" do
  redirect "/index"
end

get "/index" do
  @title = "ホーム"
  @header_title = "掲示板"
  @threads = params["board"] == nil ? $threadManager.chatThreads : $threadManager.chatThreads.select { |thread| thread.board == params["board"] }
  @boards = ChatBoard::Board.all

  erb:index
end

get "/search" do
  @title = "検索"
  @header_title = "掲示板"
  
  erb:search
end

get "/thread" do
  @title = "スレッド"
  @header_title = "掲示板"
  
  erb:thread
end

post "/api/create_thread" do
  title = params[:title]
  board = params[:board]
  message = params[:message]

  if title.nil? || board.nil? || message.nil?
    halt 400, "Bad request"
  end

  if title.length > 64
    halt 400, "Title too long"
  end

  if ChatBoard::Board.get(board) == nil
    halt 400, "Invalid board number"
  end

  if message.length > 1000
    halt 400, "Message too long"
  end

  chatThread = ChatBoard::ChatThread.new(title, board, [message])
  $threadManager.chatThreads.push chatThread
  "ID: #{chatThread.id}, Title: #{chatThread.title}, Board: #{chatThread.board}, Message: #{chatThread.messages[0]}, CreateTime: #{chatThread.time_stamp.strftime("%Y/%m/%d %H:%M:%S")}"
end
