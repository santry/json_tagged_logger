require 'active_support'
require 'active_support/tagged_logging'

module JsonTaggedLogger
  module Logger
    def self.new(logger, pretty_print: false)
      logger.formatter = Formatter.new(pretty_print: pretty_print)
      ActiveSupport::TaggedLogging.new(logger)
    end
  end
end
