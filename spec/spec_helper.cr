require "spec"
require "../src/discordcr-plugin"

# A mock Discord message
record Message, id : Int32, channel_id : Int32, content : String

# A mock Discord channel
record ChannelStub, id : Int32, name : String

# A mock Discord client with altered behavior that allows for testing
class MockClient
  getter logger : Logger? = Logger.new(STDOUT)

  def register(plugin : Discord::Plugin)
    plugin.register_on(self)
  end

  def on_message_create(&block : Message ->)
  end

  def on_message_create(*middleware, &block : Message ->)
  end

  def on_channel_create(&block : ChannelStub ->)
  end

  def create_message(channel_id : Int32, content : String)
    Message.new(2, channel_id, content)
  end

  def edit_message(channel_id, message_id, content)
    Message.new(message_id, channel_id, content)
  end
end
