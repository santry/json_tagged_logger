module JsonTaggedLogger
  module TagFromSession
    def self.get(log_label, session_key = log_label)
      lambda do |request|
        { log_label => get_value_from_session(request, session_key) }.to_json
      end
    end

    private

    def self.get_value_from_session(request, key)
      session_options = Rails.application.config.session_options
      session_store = Rails.application.config.session_store.new(Rails.application, session_options)
      session = ActionDispatch::Request::Session.create(session_store, request, session_options)

      session[key]
    ensure
      # Clean up side effects from loading the session so it can be loaded as
      # usual during the normal request cycle. Leaving these headers in place
      # seems to break some RSpec specs that interact with the session.
      request.delete_header("rack.session")
      request.delete_header("rack.session.options")
    end
  end
end
