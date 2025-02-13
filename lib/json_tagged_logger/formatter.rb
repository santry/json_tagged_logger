# frozen_string_literal: true

require "active_support"
require "active_support/core_ext/hash/keys"
require "json"

module JsonTaggedLogger
  class Formatter
    include ActiveSupport::TaggedLogging::Formatter

    attr_accessor :pretty_print

    def initialize(pretty_print: false)
      @pretty_print = pretty_print
    end

    def call(severity, time, _progname, message)
      log = {
        level: severity,
        time: time
      }

      json_tags, text_tags = extract_tags

      json_tags.each { |t| log.merge!(t) }

      log[:tags] = text_tags.to_a if text_tags.present?

      bare_message = message_without_tags(message.to_s)

      begin
        parsed_message = JSON.parse(bare_message)
      rescue JSON::ParserError
        parsed_message = bare_message
      ensure
        if parsed_message.is_a?(Hash)
          parsed_message.symbolize_keys!

          parsed_message[:tags] = parsed_message[:tags] + log[:tags] if log.key?(:tags) && parsed_message.key?(:tags)

          log.merge!(parsed_message)
        else
          log.merge!(msg: parsed_message.to_s.strip)
        end
      end

      format_for_output(log)
    end

    private

    def extract_tags
      json_tags = Set[]
      text_tags = Set[]

      current_tags.each do |t|
        tag = JSON.parse(t)
      rescue JSON::ParserError
        tag = t
      rescue TypeError
        tag = t.to_s
      ensure
        if tag.is_a?(Hash)
          json_tags << tag
        else
          text_tags << tag
        end
      end

      [json_tags, text_tags]
    end

    def message_without_tags(message)
      if tags_text.present?
        message.gsub(tags_text.strip, "")
      else
        message
      end
    end

    def format_for_output(log_hash)
      compacted_log = log_hash.compact

      ## It's not a call of standard method, it's our attribute
      # rubocop:disable Rails/Output
      output_json = if pretty_print
                      JSON.pretty_generate(compacted_log)
                    else
                      JSON.generate(compacted_log)
                    end
      # rubocop:enable Rails/Output

      "#{output_json}\n"
    end
  end
end
