require "discordcr"

module Discord
  annotation Handler
  end

  class Client
    def register(container : Container)
      container.register_on(self)
    end
  end

  module Container
    annotation Options
    end

    EVENTS = {
      ::Discord::Message => "on_message_create"
    }

    macro included
      {% ann = @type.annotation(::Discord::Container::Options) %}
      {% if ann && ann[:client_class] %}
        getter! client : {{ann[:client_class]}}
      {% else %}
        getter! client : ::Discord::Client
      {% end %}

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
