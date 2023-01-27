require 'sinatra/activerecord'

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

  class ChatBoardRecord < ActiveRecord::Base
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
      @chatMessages.push(ChatMessage.new(user, message))
    end
  end

  class ChatUserManager

    attr_accessor :users, :god

    def initialize()
      @users = Array.new
      @god = ChatUser.new("127.0.0.1")
      @god.name = '<span style="color: red;">神</span>'
      @god.id = '<span style="color: red">Xx_GOD_xX</span>'
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
      @ip = ip
      @name = "Anonymous"
      @id = SecureRandom.uuid
    end

    def getShortId
      shortName = @id
      if @id.length == 36
        shortName = ""
        @id.split("-").each{ |s| shortName += s[0]}
      end
      shortName
    end
  end

  class ChatMessage
    
    attr_accessor :user, :message, :time_stamp

    def initialize(user, message)
      @user = user
      @message = message
      @time_stamp = Time.new
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
