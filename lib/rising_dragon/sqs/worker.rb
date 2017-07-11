module RisingDragon
  module SQS
    module Worker
      def self.included(base)
        base.class_eval do
          include Shoryuken::Worker
        end
        base.extend(ClassMethods)
      end

      module ClassMethods
        def rising_dragon_options(sqs_queue_name, weight, group, opt = {})
          shoryuken_opt = { queue: sqs_queue_name, body_parser: :json }.merge(opt)
          shoryuken_options(shoryuken_opt)

          Shoryuken.add_queue(sqs_queue_name, weight, group)
        end

        def rising_dragon_register(event_name, handle_class)
          emitter.register(event_name, handle_class)
        end

        def rising_dragon_ignore(event_name)
          emitter.ignore(event_name)
        end

        def emitter
          @emitter ||= ::RisingDragon::SQS::Emitter.new
        end
      end

      def perform(_sqs_msg, body)
        self.class.emitter.emit_sns_msg(body)
      rescue => e
        rescue_from(e)
      end

      def rescue_from(e)
        # overwrite here
        raise e
      end
    end
  end
end
