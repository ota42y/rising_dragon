module RisingDragon
  module SQS
    class Handler
      def handle(_event)
        # overwrite here :)
        raise ::RisingDragon::UnOverwriteHandle
      end
    end

    class EmptyHandler
      def handle(_event)
      end
    end
  end
end
