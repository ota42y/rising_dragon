module RisingDragon
  module SNS
    class Publisher
      attr_accessor :use_cache
      def initialize(sns_client)
        @sns_client = sns_client
        @topic_cache = {}
        @use_cache = true # default true :)
      end

      def publish(topic_name, event_type, data)
        event = create_event(event_type, data)

        topic = get_topic(topic_name)
        @sns_client.publish(topic_arn: topic.topic_arn, message: event.to_json)
      end

      private

        def create_event(type, data)
          ::RisingDragon::Event.new(id: uuid, timestamp: unixtime, type: type, data: data, sqs_msg: nil)
        end

        def uuid
          SecureRandom.uuid
        end

        def unixtime
          (Time.now.to_f * 1000).to_i
        end

        def get_topic(topic_name)
          return create_topic(topic_name) unless @use_cache

          @topic_cache[topic_name] ||= create_topic(topic_name)
        end

        def create_topic(topic_name)
          @sns_client.create_topic(name: topic_name)
        end
    end
  end
end
