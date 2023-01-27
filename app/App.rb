require 'sinatra'
require 'sinatra/reloader' if development?
require 'json'
require "./ChatBoard.rb"

$threadManager = ChatBoard::ChatThreadManager.new
$userManager = ChatBoard::ChatUserManager.new

configure :development do
  register Sinatra::Reloader

  get "/reset" do
    $threadManager.chatThreads.clear
    redirect "/index"
  end

  post "/999/:id" do |id|
    chatThread = $threadManager.getChatThread(id)

    if chatThread.nil?
      halt 400, "Failure"
    end

    while chatThread.chatMessages.length < 999
      chatThread.postChatMessage($userManager.god, "埋め")
    end

    halt 200, "Success"
  end
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

get "/create_thread" do
  @title = "スレッド作成"
  @header_title = "掲示板"
  @boards = ChatBoard::Board.all.sort

  erb:create_thread
end

post "/api/create_thread" do
  title = ChatBoard::Utils.escapeHtml(params[:title])
  board = params[:board]
  message = ChatBoard::Utils.escapeHtml(params[:message])
  response = {
    status: "failure"
  }

  if title.nil? || board.nil? || message.nil?
    halt 400, response.to_json
  end

  if title.length > 100 || title.length < 1
    halt 400, response.to_json
  end

  if ChatBoard::Board.get(board).nil?
    halt 400, response.to_json
  end

  if message.length > 1000 || message.length < 1
    halt 400, response.to_json
  end

  user = $userManager.getUser(request.ip, true)
  chatThread = $threadManager.createChatThread(title, board, ChatBoard::ChatMessage.new(user, message))
  response = {
    status: "success",
    id: chatThread.id
  }

  halt 200, response.to_json
end

post "/api/post_message/:id" do |id|
  message = ChatBoard::Utils.escapeHtml(params[:message])
  chatThread = $threadManager.getChatThread(id)
  user = $userManager.getUser(request.ip, true)
  response = {
    status: "failure"
  }

  if chatThread.nil? || message.nil?
    halt 400, response.to_json
  end

  if message.length < 1
    halt 400, response.to_json
  end

  chatThread.postChatMessage(user, message)

  if chatThread.chatMessages.length == 1000
    chatThread.postChatMessage($userManager.god, "レス数が1000に達したゾ〜<br>これ以上は投稿できないゾ〜")
    chatThread.postChatMessage($userManager.god, "私がレスしたことで実質1001レスだけど")
    chatThread.postChatMessage($userManager.god, "いや、やっぱり1002レスだった")
    chatThread.postChatMessage($userManager.god, "いや、やっｐ...")
  end

  response = {
    status: "success"
  }

  halt 200, response.to_json
end

not_found do
  redirect "/index"
end
