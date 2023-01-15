require 'minitest/autorun'

require 'json_tagged_logger'

class TagFromSessionTest < Minitest::Test
  def setup
    @mock_request = Minitest::Mock.new
  end

  def test_get_generates_a_proc_where_label_and_session_key_are_the_same
    generated_proc = JsonTaggedLogger::TagFromSession.get(:user_id)

    JsonTaggedLogger::TagFromSession.stub(:get_value_from_session, "1234", [@mock_request, :user_id]) do
      output = generated_proc.call(@mock_request)

      expected_json = { user_id: "1234" }.to_json

      assert_equal expected_json, output
    end
  end

  def test_get_generates_a_proc_where_label_and_session_key_differ
    generated_proc = JsonTaggedLogger::TagFromSession.get(:user_id, :uid)

    JsonTaggedLogger::TagFromSession.stub(:get_value_from_session, "1234", [@mock_request, :uid]) do
      output = generated_proc.call(@mock_request)

      expected_json = { user_id: "1234" }.to_json

      assert_equal expected_json, output
    end
  end
end
