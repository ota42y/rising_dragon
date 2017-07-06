module RisingDragon
  class Event
    attr_reader :type, :data, :id, :timestamp
    def initialize(type, id, timestamp, data)
      @type = type
      @data = data
      @id = id
      @timestamp = timestamp
    end
  end
end