require 'sinatra'
require 'sinatra/reloader' if development?
require 'json'
require 'mysql2'
require 'active_support/all'
require "./ChatBoard.rb"

$threadManager = ChatBoard::ChatThreadManager.new
$userManager = ChatBoard::ChatUserManager.new
$database = Mysql2::Client.new(
  host: "app_database",
  username: "root",
  password: "root",
  port: "3306",
  database: "app",
  charset: "utf8mb4",
  encoding: "utf8mb4",
  collation: "utf8mb4_general_ci"
)
$threadManager.load($database)

configure :development do
  register Sinatra::Reloader

  post "/reset" do
    $threadManager.chatThreads.clear
    $threadManager.save($database)

    halt 200, "success"
  end

  post "/999/:id" do |id|
    chatThread = $threadManager.getChatThread(id)

    if chatThread.nil?
      halt 400, "Failure"
    end

    while chatThread.chatMessages.length < 999
      chatThread.postChatMessage($userManager.god, "埋め")
    end

    $threadManager.save($database)

    halt 200, "success"
  end
end

get "/" do
  redirect "/index"
end

get "/index" do
  @title = "ホーム - 掲示板"
  @header_title = "掲示板"
  @threads = params["board"].nil? ? $threadManager.chatThreads : $threadManager.chatThreads.select { |thread| thread.board == params["board"] }
  @boards = ChatBoard::Board.all.sort
  @currentBoard = ChatBoard::Board.get(params["board"])

  erb:index
end

get "/search" do
  @title = "検索 - 掲示板"
  @header_title = "掲示板"
  @search = params["search"]
  @results = @search.nil? ? Array.new(0) : $threadManager.chatThreads.filter{ |thread| thread.title.include?(@search) }
  
  erb:search
end

get "/thread/:id" do |id|
  chatThread = $threadManager.getChatThread(id)
  user = $userManager.getUser(request.ip, true);

  @title = chatThread.nil? ? "スレッド" : chatThread.title + " - 掲示板"
  @header_title = "掲示板"
  @thread = chatThread
  @name = user.name == "名無し" ? nil : user.name
  
  erb:thread
end

get "/create_thread" do
  @title = "スレッド作成 - 掲示板"
  @header_title = "掲示板"
  @boards = ChatBoard::Board.all.sort

  erb:create_thread
end

post "/api/create_thread" do
  title = params[:title]
  board = params[:board]
  message = params[:message]
  response = {
    status: "failure"
  }

  if title.nil? || board.nil? || message.nil?
    halt 400, response.to_json
  end

  if title.length > 100 || title.length < 1 || !title.present?
    halt 400, response.to_json
  end

  if ChatBoard::Board.get(board).nil?
    halt 400, response.to_json
  end

  if message.length > 1000 || message.length < 1 || !message.present?
    halt 400, response.to_json
  end

  user = $userManager.getUser(request.ip, true)
  chatThread = $threadManager.createChatThread(title, board, ChatBoard::ChatMessage.new(user.getShortId, user.name, message))
  $threadManager.save($database)
  response = {
    status: "success",
    id: chatThread.id
  }

  halt 200, response.to_json
end

post "/api/post_message/:id" do |id|
  message = params["message"]
  name = params["name"]
  chatThread = $threadManager.getChatThread(id)
  user = $userManager.getUser(request.ip, true)
  response = {
    status: "failure"
  }

  if chatThread.nil? || message.nil?
    halt 400, response.to_json
  end

  if message.length < 1 || message.length > 1000 || !message.present?
    halt 400, response.to_json
  end

  if chatThread.chatMessages.length >= 1000
    halt 400, response.to_json
  end

  if !name.nil? && name.present?
    user.name = name
  end
  
  chatThread.postChatMessage(user, message)

  if chatThread.chatMessages.length == 1000
    chatThread.postChatMessage($userManager.god, "コメント数が1000に達しました。\nこれ以上コメントを投稿することはできません。")
  end

  $threadManager.save($database)

  response = {
    status: "success"
  }

  halt 200, response.to_json
end

not_found do
  redirect "/index"
end
