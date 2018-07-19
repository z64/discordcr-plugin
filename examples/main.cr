require "../src/discordcr_container"
require "./container"

client = Discord::Client.new token: ENV["TOKEN"]
client.register(Container.new)
client.run
