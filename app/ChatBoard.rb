module ChatBoard
  module Board
    NANJ = "何でも実況ジュピター"
    NANG = "何でも実況ガリレオ"
    VIP = "ニュー速VIP"

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

    attr_accessor :users

    def initialize()
      @users = Array.new
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
      r = ""
      @id.split("-").each{ |s| r += s[0]}
      r
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
  end
end
