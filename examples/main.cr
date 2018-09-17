require "../src/discordcr-plugin"
require "./my_plugin"

client = Discord::Client.new token: ENV["TOKEN"]

File.open("./config.json", "r") do |file|
  parser = JSON::PullParser.new(file)
  parser.read_object do |key|
    matched = false
    Discord::Plugin.plugins.each do |plugin|
      if plugin.class.to_s.underscore == key
        plugin.configure(parser)
        matched = true
      end
    end
    parser.skip unless matched
  end
end

Discord::Plugin.plugins.each do |plugin|
  client.register(plugin)
end

client.run
