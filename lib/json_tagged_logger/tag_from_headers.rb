module JsonTaggedLogger
  module TagFromHeaders
    def self.get(*header_keys, **labeled_header_keys)
      labels = header_keys + labeled_header_keys.keys
      header_keys = header_keys + labeled_header_keys.values

      lambda do |request|
        values = header_keys.map { |hk| request.headers[hk] }
        labels.zip(values).to_h.compact.to_json
      end
    end
  end
end
