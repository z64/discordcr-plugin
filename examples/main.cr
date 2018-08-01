require "../src/discordcr_container"
require "./container"

client = Discord::Client.new token: ENV["TOKEN"]

File.open("./config.json", "r") do |file|
  parser = JSON::PullParser.new(file)
  parser.read_object do |key|
    Discord::Container.containers.each do |container|
      if container.class.to_s.underscore == key
        container.configure(parser)
      else
        parser.skip
      end
    end
  end
end

Discord::Container.containers.each do |container|
  client.register(container)
end

client.run
