module JsonTaggedLogger
  module Logger
    def self.new(logger)
      logger.formatter = Formatter.new
      ActiveSupport::TaggedLogging.new(logger)
    end
  end
end
