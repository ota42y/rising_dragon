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
        def rising_dragon_options(sqs_queue_name, opt = {})
          shoryuken_opt = { queue: sqs_queue_name, body_parser: :json, auto_delete: true, shoryuken_group: 'default' }.merge(opt)
          shoryuken_options(shoryuken_opt)

          register_queue(sqs_queue_name, shoryuken_opt['shoryuken_group'], opt) # shoryuken_options will change hash key.... :(
        end

        def register_queue(sqs_queue_name, group_name, option)
          concurrency = option['concurrency'] || 25
          Shoryuken.add_group(group_name, concurrency)

          weight = option['weight'] || 1
          Shoryuken.add_queue(sqs_queue_name, weight, group_name)
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

      def perform(sqs_msg, body)
        self.class.emitter.emit_sqs_msg(sqs_msg, body)
      rescue StandardError => e
        rescue_from(e)
      end

      def rescue_from(e)
        # overwrite here
        raise e
      end
    end
  end
end
