# frozen_string_literal: true

require "action_dispatch"

module JsonTaggedLogger
  module TagFromSession
    class << self
      def get(*simple_tags, **labeled_tags)
        labels = simple_tags + labeled_tags.keys
        session_keys = simple_tags + labeled_tags.values

        lambda do |request|
          values = get_values_from_session(request, session_keys)
          labels.zip(values).to_h.compact.to_json
        end
      end

      def get_values_from_session(request, keys)
        session_options = Rails.application.config.session_options
        session_store = Rails.application.config.session_store.new(Rails.application, session_options)
        session = ActionDispatch::Request::Session.create(session_store, request, session_options)

        keys.map { |k| session[k] }
      ensure
        # Clean up side effects from loading the session so it can be loaded as
        # usual during the normal request cycle. Leaving these headers in place
        # seems to break some RSpec specs that interact with the session.
        request.delete_header("rack.session")
        request.delete_header("rack.session.options")
      end
    end
  end
end
