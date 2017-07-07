require 'shoryuken'

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
        def rising_dragon_options(opt = {})
          shoryuken_options(opt)
        end

        def register_handlers(_emitter)
          raise 'Overwrite self.register_handlers'
        end

        def emitter
          return @emitter if @emitter

          @emitter = ::RisingDragon::SQS::Emitter.new
          register_handlers(@emitter)
          @emitter
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
