require 'json'

module ChatBoard
  module Board
    ANIME = "アニメ板"
    MANGA = "漫画板"
    ILLUST = "イラスト板"
    GAME = "ゲーム板"
    NEWS = "ニュース板"
    JOBS = "仕事板"
    SPORTS = "スポーツ板"
    SMALL_TALK = "何でも雑談板"
    LIVE_COMMENTARY = "何でも実況板"
    SCHOOL = "学校板"
    PROGRAMMING = "プログラミング板"
    LAWLESS_AREA = "無法地帯板"
    LINUX = "Linux板"
    WINDOWS = "Windows板"
    MAC = "MacOS板"
    SERVER = "サーバー板"
    HARDWARE = "ハードウェア板"
    SOFTWARE = "ソフトウェア板"
    HOMEMADE_PC = "自作PC板"
    STUDENT = "学生板"
    TEACHER = "教員板"
    EXAM = "受験板"
    BUSINESS = "ビジネス板"
    KK = "株板"
    SECURITY = "情報セキュリティ板"
    WEB = "ウェブ制作板"
    ROMANCE = "恋愛板"
    STUDY = "勉強板"
    LIFE = "人生板"
    FAMILY = "家族板"
    SOCIETY = "社会板"
    SPACE = "宇宙板"
    HEALTH = "健康板"
    BEAUTY = "美容板"
    FASHION = "ファッション板"
    COOKING = "料理板"
    GOURMET = "グルメ板"
    TRAVEL = "旅行板"
    HEALING = "癒やし板"
    PET = "ペット板"
    PLANT = "植物板"
    FARMING = "農業板"
    AREA = "地域板"
    GEOGRAPHY = "地理板"
    SCIENCE = "科学板"
    MATH = "数学板"
    NATIONAL_LANGUAGE = "国語板"
    PHYSICS = "物理板"
    CALTURE = "趣味板"

    def self.all
      self.constants
    end

    def self.values
      self.constants.map{ |board| eval("#{board}") }
    end

    def self.get(b)
      list = self.constants.filter{ |board| b == board || b == board.to_s }.map{ |board| eval("#{board}") }
      list.length > 0 ? list[0] : nil
    end
  end

  class ChatThreadManager
    attr_accessor :chatThreads

    def initialize()
      @chatThreads = Array.new
    end

    def createChatThread(title, board, firstChatMessage)
      chatThread = ChatThread.new(title, board, firstChatMessage)
      @chatThreads.push(chatThread)
      chatThread
    end

    def getChatThread(id)
      list = @chatThreads.filter{ |thread| thread.id == id }
      list.length > 0 ? list[0] : nil
    end

    def load(database)
      database.query("SELECT * FROM thread").each do |thread|
        begin
          json = JSON.parse(thread["json"])
          messages = []
          json["messages"].each do |message|
            chatMessage = ChatMessage.load(message["id"], message["name"], message["message"], Time.parse(message["time_stamp"]))
            messages.push(chatMessage)
          end
        rescue Exception
          p "スレッド #{thread["id"]} の読み込みに失敗しました。"
          next
        end

        chatThread = ChatThread.load(json["id"], json["title"], json["board"], messages, Time.parse(json['time_stamp']))
        @chatThreads.push(chatThread)
      end
    end

    // TODO 絵文字を保存できないバグ修正
    def save(database)
      @chatThreads.each do |chatThread|
        escapedChatThread = chatThread.serialize.to_json.gsub("\"", "\\\"")
        database.query("DELETE FROM thread WHERE id=\"#{chatThread.id}\"")
        database.query("INSERT INTO thread VALUES (\"#{chatThread.id}\", \"#{escapedChatThread}\")")
      end
      
      database.query("SELECT * FROM thread").each do |chatThread|
        if @chatThreads.filter{|t| t.id == chatThread["id"]}.length == 0
          database.query("DELETE FROM thread WHERE id=\"#{chatThread["id"]}\"")
        end
      end
    end
  end

  class ChatThread
    require 'securerandom'

    attr_accessor :id, :title, :board, :chatMessages, :time_stamp

    def initialize(title, board, firstChatMessage)
      @id = SecureRandom.uuid
      @title = title
      @board = board
      @chatMessages = [firstChatMessage]
      @time_stamp = Time.new
    end

    def postChatMessage(user, message)
      @chatMessages.push(ChatMessage.new(user.getShortId, user.name, message))
    end

    def serialize
      messages = []
      @chatMessages.each do |chatMessage|
        messages.push(chatMessage.serialize)
      end

      {
        id: @id,
        title: @title,
        board: @board,
        messages: messages,
        time_stamp: @time_stamp
      }
    end

    def self.load(id, title, board, chatMessages, time_stamp)
      chatThread = ChatThread.new(title, board, "")
      chatThread.id = id
      chatThread.title = title
      chatThread.board = board
      chatThread.chatMessages = chatMessages
      chatThread.time_stamp = time_stamp
      chatThread
    end
  end

  class ChatUserManager

    attr_accessor :users, :god

    def initialize()
      @users = Array.new
      @god = ChatUser.new("127.0.0.1")
      @god.name = '神'
      @god.id = 'Xx_GOD_becomes_GOD_:)_xX'
    end

    def registerUser(ip)
      user = ChatUser.new(ip)
      @users.push user
      user
    end

    def getUser(ip, create)
      list = @users.filter{ |user| user.ip == ip }
      list.length > 0 ? list[0] : create == true ? registerUser(ip) : nil
    end
  end

  class ChatUser
    require 'securerandom'

    attr_accessor :ip, :id, :name

    def initialize(ip)
      @name = "名無し"
      @ip = ip
      @id = SecureRandom.uuid
    end

    def getShortId
      shortId = @id
      if @id.length == 36
        shortId = ""
        @id.split("-").each{ |s| shortId += s[0]}
      end
      shortId
    end
  end

  class ChatMessage
    
    attr_accessor :id, :name, :message, :time_stamp

    def initialize(id, name, message)
      @id = id;
      @name = name
      @message = message
      @time_stamp = Time.new
    end

    def serialize()
      {
        id: @id.clone.gsub("\"", "\\\""),
        name: @name.clone.gsub("\"", "\\\""),
        message: @message.clone.gsub("\"","\\\""),
        time_stamp: @time_stamp
      }
    end

    def self.load(id, name, message, time_stamp)
      chatMessage = ChatMessage.new(id, name, message)
      chatMessage.id = id
      chatMessage.name = name
      chatMessage.message = message
      chatMessage.time_stamp = time_stamp
      chatMessage
    end
  end

  class Utils
    def self.toDisplayTime(time)
      time.strftime("%Y/%m/%d %H:%M:%S")
    end

    def self.escapeHtml(str)
      s = str.gsub("&", "%amp;")
      s = s.gsub("<", "&lt;")
      s = s.gsub(">", "&gt;")
      s = s.gsub("\"", "&quot;")
      s = s.gsub("'", "&#39;")
      s = s.gsub("\n", "<br>")
      s
    end
  end
end
