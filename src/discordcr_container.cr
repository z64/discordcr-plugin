require "discordcr"

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
  # module MyHandlers
  #  include Discord::Container
  #
  #  @[Discord::Handler(payload: ::Discord::Message)
  #  def ping(payload)
  #    return unless payload.content == "!ping"
  #    client.create_message(payload.channel_id, "pong!")
  #  end
  # end
  # ```
  #
  # `client` will reference the `Client` instance the container was registered
  # onto. It can also be replaced by any other class using the
  # `@[Container::Options(client_class: MyClient)]` annotation. This is useful
  # for replacing it for a mock client for use in specs.
  module Container
    annotation Options
    end

    EVENTS = {
      ::Discord::Message => "on_message_create",
    }

    macro included
      {% ann = @type.annotation(::Discord::Container::Options) %}
      {% if ann && ann[:client_class] %}
        getter! client : {{ann[:client_class]}}
      {% else %}
        getter! client : ::Discord::Client
      {% end %}

      # Registers this containers handlers onto the given `client`
      def register_on(client)
        @client = client
        {% verbatim do %}
          {% for method in @type.methods %}
            {% ann = method.annotation(::Discord::Handler) %}
            {% if ann %}
              {% handler_method = EVENTS[ann[:payload]] %}
              {% raise "Unknown event type: #{ann[:payload]}" if handler_method.is_a?(NilLiteral) %}
              client.{{handler_method.id}} do |payload|
                {{method.name}}(payload)
              end
            {% end %}
          {% end %}
        {% end %}
      end
    end
  end
end
