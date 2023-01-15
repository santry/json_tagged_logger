module JsonTaggedLogger
  class Formatter
    def call(severity, _time, _progname, message)
      log = {
        level: severity,
      }

      json_tags, text_tags = extract_tags

      json_tags.each { |t| log.merge!(t) }

      if text_tags.present?
        log[:tags] = text_tags
      end

      bare_message = message_without_tags(message)

      begin
        parsed_message = JSON.parse(bare_message)
      rescue JSON::ParserError
        parsed_message = bare_message
      ensure
        if parsed_message.is_a?(Hash)
          log.merge!(parsed_message.symbolize_keys)
        else
          log.merge!(msg: parsed_message.strip)
        end
      end

      log.compact.to_json + "\n"
    end

    private

    def extract_tags
      json_tags = Set[]
      text_tags = Set[]

      current_tags.each do |t|
        begin
          tag = JSON.parse(t)
        rescue JSON::ParserError
          tag = t
        ensure
          if tag.is_a?(Hash)
            json_tags << tag
          else
            text_tags << tag
          end
        end
      end

      [json_tags, text_tags]
    end

    def message_without_tags(message)
      if tags_text.present?
        message.gsub(tags_text.strip, '')
      else
        message
      end
    end
  end
end
