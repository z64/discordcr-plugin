require "../src/discordcr_container"
require "./container"

client = Discord::Client.new token: ENV["TOKEN"]

Discord::Container.containers.each do |container|
  client.register(container)
end

client.run
