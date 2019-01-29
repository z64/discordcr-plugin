require "./spec_helper"

describe PrefixMiddleware do
  it "yields on matching message" do
    mw = PrefixMiddleware.new("!")

    matching = Message.new(1, 1, "!foo")
    ignored = Message.new(1, 1, "?foo")

    called = false
    mw.call(matching, :ctx) { called = true }
    called.should eq true

    called = false
    mw.call(ignored, :ctx) { called = true }
    called.should eq false
  end
end

describe ChannelFilter do
  it "yields on matching message" do
    mw = ChannelFilter.new(999)

    matching = Message.new(1, 999, "foo")
    ignored = Message.new(1, 1, "foo")

    called = false
    mw.call(matching, :ctx) { called = true }
    called.should eq true

    called = false
    mw.call(ignored, :ctx) { called = true }
    called.should eq false
  end
end
