module JsonTaggedLogger
  module TagFromHeaders
    def self.get(log_label, header_key)
      lambda do |request|
        { log_label => request.headers[header_key] }.to_json
      end
    end
  end
end
