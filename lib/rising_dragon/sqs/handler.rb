module RisingDragon
  module SQS
    class Handler
      def handle(_event)
        # overwrite here :)
        raise ::RisingDragon::UnOverwriteHandle
      end
    end
  end
end
