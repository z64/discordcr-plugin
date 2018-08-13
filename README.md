# discordcr-plugin

TODO: Write a description here

## Installation

Add this to your application's `shard.yml`:

```yaml
dependencies:
  discordcr-plugin:
    github: z64/discordcr-plugin
```

## Usage

```crystal
# my_commands.cr

# Describe a plugin with two middleware that will filter incoming
# events for every event handler in this plugin
@[Discord::Plugin::Options(middleware: {Prefix.new("!"), ChannelFilter.new(123)})]
class MyCommands
  # Create a message_create handler method
  @[Discord::Handler(event: :message_create)]
  def do_something(payload, ctx)
    # Access the client anywhere:
    client.create_message(payload.channel_id, "test")
  end

  @[Discord::Handler(event: :message_create)]
  def command_b(payload, ctx)
    # ..
  end

  # Functions without annotations are ignored, can be defined for internal
  # helper methods
  def some_helper_function(arg)
    # ..
  end

  # Use JSON/YAML configure hooks:
  record Config, some_option : Bool do
    include JSON::Serializable
    include YAML::Serializable
  end

  @config : Config?

  def configure(parser : JSON::PullParser)
    @config = Config.new(parser)
  end

  def configure(parser : YAML::PullParser)
    @config = Config.new(parser)
  end
end

# main.cr

require "discordcr-plugin"
require "./my_commands"

# Make a client (or many!)
client = Discord::Client.new(token: ENV["TOKEN"])

# Configure all plugins based on their class name:
File.open("config.json", "r") do |file|
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

# Register all plugins defined across the codebase:
Discord::Plugin.plugins.each do |plugin|
  client.register(plugin)
end

# Let's go!
client.run
```

TODO: Write usage instructions here

## Contributors

- [z64](https://github.com/z64) Zac Nowicki - creator, maintainer
