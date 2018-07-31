class Container
  include Discord::Container

  @[Discord::Handler(payload: ::Discord::Message)]
  def ping(payload)
    return unless payload.content == "!ping"
    client.create_message(payload.channel_id, "pong")
  end

  @[Discord::Handler(payload: ::Discord::Message)]
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
