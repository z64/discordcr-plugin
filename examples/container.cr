class PrefixMiddleware
  def initialize(@prefix : String)
  end

  def call(payload, ctx)
    yield if payload.content.starts_with?(@prefix)
  end
end

class Container
  include Discord::Container

  record Config, show_response_time : Bool do
    include JSON::Serializable
    include YAML::Serializable
  end

  getter config : Config?

  def configure(parser : JSON::PullParser)
    @config = Config.new(parser)
  end

  @[Discord::Handler(event: :message_create, middleware: PrefixMiddleware.new("!"))]
  def ping(payload, ctx)
    return unless payload.content == "!ping"

    message = nil
    time = Time.measure do
      message = client.create_message(payload.channel_id, "pong")
    end

    config.try do |c|
      if c.show_response_time && message
        message = client.edit_message(payload.channel_id, message.id, "pong (`#{time}`)")
      end
    end

    message
  end

  @[Discord::Handler(event: :message_create)]
  def add(payload)
    input = payload.content
    return unless input.starts_with?("!add")
    numbers = parse_numbers(input[4..-1])
    client.create_message(payload.channel_id, numbers.sum.to_s)
  rescue ArgumentError
    client.create_message(payload.channel_id, "Invalid numbers")
  end

  private def parse_numbers(string : String)
    string.split(' ', remove_empty: true).map(&.to_i)
  end
end
