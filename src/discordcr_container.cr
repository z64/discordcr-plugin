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

    macro included
      {% ann = @type.annotation(::Discord::Container::Options) %}
      {% if ann && ann[:client_class] %}
        getter! client : {{ann[:client_class]}}
      {% else %}
        getter! client : ::Discord::Client
      {% end %}

      def register_on(client)
        @client = client
        \{% for method in @type.methods %}
          \{% ann = method.annotation(::Discord::Handler) %}
          \{% if ann %}
             client.\{{ann[:event]}} do |payload|
               \{{method.name}}(payload)
             end
          \{% end %}
        \{% end %}
      end
    end
  end
end
