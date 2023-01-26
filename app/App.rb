require 'sinatra'
require 'sinatra/reloader' if development?
require 'json'
require "./ChatBoard.rb"

$threadManager = ChatBoard::ChatThreadManager.new
$userManager = ChatBoard::ChatUserManager.new

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
  @threads = params["board"].nil? ? $threadManager.chatThreads : $threadManager.chatThreads.select { |thread| thread.board == params["board"] }
  @boards = ChatBoard::Board.all.sort
  @currentBoard = ChatBoard::Board.get(params["board"])

  erb:index
end

get "/search" do
  @title = "検索"
  @header_title = "掲示板"
  
  erb:search
end

get "/thread/:id" do |id|
  chatThread = $threadManager.getChatThread(id)

  @title = chatThread.nil? ? "スレッド" : chatThread.title + " - 掲示板"
  @header_title = "掲示板"
  @thread = chatThread
  
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

  if ChatBoard::Board.get(board).nil?
    halt 400, "Invalid board number"
  end

  if message.length > 1000
    halt 400, "Message too long"
  end

  user = $userManager.getUser(request.ip, true)
  chatThread = $threadManager.createChatThread(title, board, ChatBoard::ChatMessage.new(user, message))

  halt 200, "ID: #{chatThread.id}, Title: #{chatThread.title}, Board: #{chatThread.board}, Message: #{chatThread.chatMessages[0].message}, CreateTime: #{chatThread.time_stamp.strftime("%Y/%m/%d %H:%M:%S")}"
end

post "/api/post_message/:id" do |id|
  message = params[:message]
  message = message.gsub("&", "%amp;")
  message = message.gsub("<", "&lt;")
  message = message.gsub(">", "&gt;")
  message = message.gsub("\"", "&quot;")
  message = message.gsub("'", "&#39;")
  message = message.gsub("\n", "<br>")
  chatThread = $threadManager.getChatThread(id)
  user = $userManager.getUser(request.ip, true)
  response = {
    status: "failure"
  }

  if chatThread.nil?
    halt 400, response.to_json
  end

  if message.nil?
    halt 400, response.to_json
  end

  chatThread.postChatMessage(user, message)
  response = {
    status: "success"
  }

  halt 200, response.to_json
end

not_found do
  redirect "/index"
end
