require "./spec_helper"
require "../examples/container"

# Our container class is reopened to execute the `included` macro hook again,
# so that the annotation is applied to change the client type to our own
# `MockClient`
@[Discord::Container::Options(client_class: MockClient)]
class Container
  include Discord::Container
end

describe Container do
  container = Container.new
  container.register_on(MockClient.new)

  describe "ping" do
    it "responds with pong" do
      container.ping(Message.new(1, "foo")).should eq nil
      container.ping(Message.new(1, "!ping")).should eq({1, "pong"})
    end
  end

  describe "add" do
    it "adds two numbers" do
      container.add(Message.new(1, "!add 2 3")).should eq({1, "5"})
      container.add(Message.new(1, "!add")).should eq({1, "0"})
      container.add(Message.new(1, "!add a 3")).should eq({1, "Invalid numbers"})
    end
  end
end
