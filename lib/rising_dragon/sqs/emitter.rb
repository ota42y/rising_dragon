module RisingDragon
  module SQS
    class Emitter
      def initialize
        @handlers = {}
      end

      def register(event_name, handler_class)
        unless event_name.is_a?(String)
          raise "event_name must be String, but it's #{event_name.class}. event_name: #{event_name}"
        end
        if @handlers[event_name]
          raise "RisingDragon::SQS::Emitter accepts only one callback per event. event_name: #{event_name}"
        end
        @handlers[event_name] = handler_class
      end

      def unregister(event_name)
        unless event_name.is_a?(String)
          raise "event_name must be String, but it's #{event_name.class}. event_name: #{event_name}"
        end

        @handlers.delete(event_name)
      end

      def ignore(event_name)
        unless event_name.is_a?(String)
          raise "event_name must be String, but it's #{event_name.class}. event_name: #{event_name}"
        end

        @handlers[event_name] = ::RisingDragon::SQS::EmptyHandler
      end

      def list
        @handlers.keys
      end

      def emit_event(event)
        handler = @handlers[event.type]
        raise ::RisingDragon::UnRegisterEvent unless handler

        handler.new.handle(event)

        nil
      end

      def event_from_json(body)
        msg = JSON.parse(body["Message"])

        id = msg["id"]
        type = msg["type"]
        timestamp = Time.at(msg["timestamp"] / 1000.0)
        data = msg["data"]

        ::RisingDragon::Event.new(id: id, type: type, timestamp: timestamp, data: data)
      end

      def emit_sns_msg(body)
        event = event_from_json(body)
        emit_event(event)
      end
    end
  end
end
