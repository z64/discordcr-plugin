require "../src/discordcr-plugin"
require "./my_plugin"

client = Discord::Client.new token: ENV["TOKEN"]

File.open("./config.json", "r") do |file|
  parser = JSON::PullParser.new(file)
  parser.read_object do |key|
    Discord::Plugin.plugins.each do |plugin|
      if plugin.class.to_s.underscore == key
        plugin.configure(parser)
      else
        parser.skip
      end
    end
  end
end

Discord::Plugin.plugins.each do |plugin|
  client.register(plugin)
end

client.run
