require "spec"
require "../src/discordcr_container"

# A mock Discord message
record Message, channel_id : Int32, content : String

# A mock Discord client with altered behavior that allows for testing
class MockClient
  def register(container : Discord::Container)
    container.register_on(self)
  end

  def on_message_create(&block : Message ->)
  end

  def create_message(id : Int32, content : String)
    {id, content}
  end
end
