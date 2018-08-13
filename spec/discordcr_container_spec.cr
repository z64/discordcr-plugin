require "./spec_helper"
require "../examples/container"

# Our container class is reopened to execute the `included` macro hook again,
# so that the annotation is applied to change the client type to our own
# `MockClient`
@[Discord::Container::Options(client_class: MockClient, middleware: PrefixMiddleware.new("!"))]
class Container
  include Discord::Container
end

describe Container do
  container = Container.new
  container.register_on(MockClient.new)

  describe "ping" do
    it "responds with pong" do
      container.ping(Message.new(1, 1, "foo"), nil).should eq nil
      container.ping(Message.new(1, 1, "!ping"), nil).should eq(Message.new(2, 1, "pong"))
    end

    context "when configured" do
      configured_container = Container.new
      configured_container.register_on(MockClient.new)

      it "changes the ping command" do
        configured_container.configure JSON::PullParser.new(%({"show_response_time":true}))
        response = configured_container.ping(Message.new(1, 1, "!ping"), nil)
        expected = Message.new(1, 1, "pong (placeholder)")
        expected.id.should eq 1
        expected.channel_id.should eq 1
        /pong \(`\d+:\d+:\d+\.\d+`\)/.match(response.not_nil!.content).should be_a Regex::MatchData
      end
    end
  end

  describe "add" do
    it "adds two numbers" do
      container.add(Message.new(1, 1, "!add 2 3"), nil).should eq(Message.new(2, 1, "5"))
      container.add(Message.new(1, 1, "!add"), nil).should eq(Message.new(2, 1, "0"))
      container.add(Message.new(1, 1, "!add a 3"), nil).should eq(Message.new(2, 1, "Invalid numbers"))
    end
  end
end
