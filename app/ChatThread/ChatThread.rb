require 'securerandom'

class ChatThread
  attr_accessor :id, :title, :board, :messages, :time

  def initialize(title, board, messages)
    @id = SecureRandom.uuid
    @title = title
    @board = board
    @messages = messages
    @time = Time.new
  end
end
