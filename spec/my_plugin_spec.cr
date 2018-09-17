require "./spec_helper"

# Our plugin class is reopened to execute the `included` macro hook again,
# so that the annotation is applied to change the client type to our own
# `MockClient`
@[Discord::Plugin::Options(client_class: MockClient, middleware: ChannelFilter.new(123))]
class MyPlugin
  include Discord::Plugin
end

describe MyPlugin do
  plugin = MyPlugin.new
  plugin.register_on(MockClient.new)

  describe "ping" do
    it "responds with pong" do
      plugin.ping(Message.new(1, 1, "foo"), nil).should eq nil
      plugin.ping(Message.new(1, 1, "!ping"), nil).should eq(Message.new(2, 1, "pong"))
    end

    context "when configured" do
      configured_plugin = MyPlugin.new
      configured_plugin.register_on(MockClient.new)

      it "changes the ping command" do
        configured_plugin.configure JSON::PullParser.new(%({"show_response_time":true}))
        response = configured_plugin.ping(Message.new(1, 1, "!ping"), nil)
        expected = Message.new(1, 1, "pong (placeholder)")
        expected.id.should eq 1
        expected.channel_id.should eq 1
        /pong \(`\d+:\d+:\d+\.\d+`\)/.match(response.not_nil!.content).should be_a Regex::MatchData
      end
    end
  end

  describe "add" do
    it "adds two numbers" do
      plugin.add(Message.new(1, 1, "!add 2 3"), nil).should eq(Message.new(2, 1, "5"))
      plugin.add(Message.new(1, 1, "!add"), nil).should eq(Message.new(2, 1, "0"))
      plugin.add(Message.new(1, 1, "!add a 3"), nil).should eq(Message.new(2, 1, "Invalid numbers"))
    end
  end
end
