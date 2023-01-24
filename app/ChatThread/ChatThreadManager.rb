class ChatThreadManager
  attr_accessor :chatThreads

  def initialize()
    $instance = self
    @chatThreads = Array.new
  end
end
