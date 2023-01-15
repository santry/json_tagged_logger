module JsonTaggedLogger
  class LogTagsConfig
    def self.generate(*tags)
      tags.map do |tag|
        if tag.is_a?(Proc) && tag.arity == 1
          tag
        elsif tag.is_a?(Symbol) && ActionDispatch::Request.method_defined?(tag)
          -> (request) { { tag => request.send(tag) }.to_json }
        else
          raise ArgumentError, "Only symbols that ActionDispatch::Request responds to or single-argument Procs allowed. You provided '#{tag.inspect}'."
        end
      end
    end
  end
end
