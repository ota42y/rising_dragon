module RisingDragon
  class Event
    attr_reader :id, :type, :timestamp, :data
    def initialize(id:, type:, timestamp:, data:, sqs_msg:)
      @id = id
      @type = type
      @timestamp = timestamp
      @data = data
      @sqs_msg = sqs_msg
    end

    def to_json(*option)
      {
        id: @id,
        type: @type,
        timestamp: @timestamp,
        data: @data,
      }.to_json(*option)
    end

    def delete!
      @sqs_msg.delete
    end
  end
end
