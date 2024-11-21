require 'active_support'

module JsonTaggedLogger
  module Logger
    def self.new(logger, pretty_print: false)
      logger = logger.clone
      logger.formatter =  JsonTaggedLogger::Formatter.new(pretty_print: pretty_print)
      logger.extend(self)
    end

    delegate :push_tags, :pop_tags, :clear_tags!, to: :formatter

    def tagged(*tags)
      if block_given?
        formatter.tagged(*tags) { yield self }
      else
        logger = JsonTaggedLogger::Logger.new(self)
        logger.formatter = JsonTaggedLogger::Formatter.new
        logger.push_tags(*formatter.current_tags, *tags)
        logger
      end
    end

  end
end
