module ChatBoard
  module Board
    NANJ = "何でも実況ジュピター"
    VIP = "VIP"

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
  end

  class ChatThread
    require 'securerandom'

    attr_accessor :id, :title, :board, :messages, :time_stamp

    def initialize(title, board, messages)
      @id = SecureRandom.uuid
      @title = title
      @board = board
      @messages = messages
      @time_stamp = Time.new
    end

    def getStrTime
      @time_stamp.strftime("%Y/%m/%d %H:%M:%S")
    end
  end
end
