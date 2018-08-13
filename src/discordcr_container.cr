require "yaml"
require "discordcr"
require "discordcr-middleware"

module Discord
  annotation Handler
  end

  class Client
    def register(container : Container)
      container.register_on(self)
    end
  end

  # Represents a collection of event handlers bound to methods that can
  # be registered onto a client instance. Containers are defined by
  # `include Container`, and then using the `Discord::Handler` annotation
  # to assign an event handler to that method. Any method that does not
  # have this annotation is ignored, so that you can build private
  # helper methods for your handler.
  #
  # ```
  # @[Discord::Container::Options(middleware: {Prefix.new("!"), ChannelFilter.new(1234)})]
  # class MyHandlers
  #  include Discord::Container
  #
  #  def intialize(@prefix : String)
  #  end
  #
  #  @[Discord::Handler(event: :message_create)
  #  def ping(payload)
  #    return unless payload.content == "#{@prefix}ping"
  #    client.create_message(payload.channel_id, "pong!")
  #  end
  # end
  #
  # client.register MyHandlers.new(prefix: "!")
  # ```
  #
  # `client` will reference the `Client` instance the container was registered
  # onto. It can also be replaced by any other class using the
  # `@[Container::Options(client_class: MyClient)]` annotation. This is useful
  # for replacing it for a mock client for use in specs.
  #
  # `@[Container::Options(middleware: some_middleware)` can also be used to
  # supply a single middleware, or a tuple of middleware (a chain) that will
  # be applied to every event handler in the container.
  module Container
    annotation Options
    end

    # Reference to containers defined across the application
    class_getter containers = [] of Container

    # :nodoc:
    EVENTS = {
      :dispatch,
      :ready,
      :resumed,
      :channel_create,
      :channel_update,
      :channel_delete,
      :channel_pins_update,
      :guild_create,
      :guild_update,
      :guild_delete,
      :guild_ban_add,
      :guild_ban_remove,
      :guild_emoji_update,
      :guild_integrations_update,
      :guild_member_remove,
      :guild_members_chunk,
      :guild_role_create,
      :guild_role_update,
      :guild_role_delete,
      :message_create,
      :message_reaction_add,
      :message_reaction_remove,
      :message_reaction_remove_all,
      :message_update,
      :message_delete,
      :message_delete_bulk,
      :presence_update,
      :typing_start,
      :voice_state_update,
      :voice_server_update,
      :webhooks_update,
    }

    # Callback to be overidden in subclasses for JSON configuration
    # of a container
    def configure(parser : JSON::PullParser)
      parser.skip
    end

    # Callback to be overidden in subclasses for YAML configuration
    # of a container
    def configure(parser : YAML::PullParser)
      parser.skip
    end

    macro included
      {% class_ann = @type.annotation(::Discord::Container::Options) %}
      {% if class_ann && class_ann[:client_class] %}
        getter! client : {{class_ann[:client_class]}}
      {% else %}
        getter! client : ::Discord::Client
      {% end %}

      ::Discord::Container.containers << self.new

      # Registers this containers handlers onto the given `client`
      def register_on(client)
        @client = client
        \{% for method in @type.methods %}
          \{% ann = method.annotation(::Discord::Handler) %}
          \{% if ann %}
            \{% handler_method = ann[:event] %}
            \{% raise "Unknown event type: #{handler_method}" unless EVENTS.includes?(handler_method) %}

            {% middleware_list = class_ann[:middleware] %}
            {% if middleware_list.is_a?(NilLiteral) %}
              client.on_\{{handler_method.id}} do |payload|
                \{{method.name}}(payload)
              end
            {% else %}
              {% if middleware_list.is_a?(TupleLiteral) %}
                client.on_\{{handler_method.id}}({{middleware_list.join(",").id}}) do |payload, ctx|
                  \{{method.name}}(payload, ctx)
                end
              {% else %}
                client.on_\{{handler_method.id}}({{middleware_list}}) do |payload, ctx|
                  \{{method.name}}(payload, ctx)
                end
              {% end %}
            {% end %}
          \{% end %}
        \{% end %}
      end
    end
  end
end
