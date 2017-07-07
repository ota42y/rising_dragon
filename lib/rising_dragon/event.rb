module RisingDragon
  class Event
    attr_reader :id, :type, :timestamp, :data
    def initialize(id:, type:, timestamp:, data:)
      @id = id
      @type = type
      @timestamp = timestamp
      @data = data
    end
  end
end
