require 'active_support'
require 'active_support/tagged_logging'

module JsonTaggedLogger
  module Logger
    def self.new(logger)
      logger.formatter = Formatter.new
      ActiveSupport::TaggedLogging.new(logger)
    end
  end
end
