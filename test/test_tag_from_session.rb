# frozen_string_literal: true

require "minitest/autorun"

require "json_tagged_logger"

class TagFromSessionTest < Minitest::Test
  def setup
    @mock_request = Minitest::Mock.new
  end

  def test_get_generates_a_simple_tag_proc
    generated_proc = JsonTaggedLogger::TagFromSession.get(:user_id)

    JsonTaggedLogger::TagFromSession.stub(:get_values_from_session, ["1234"], [@mock_request, [:user_id]]) do
      output = generated_proc.call(@mock_request)

      expected_json = { user_id: "1234" }.to_json

      assert_equal expected_json, output
    end
  end

  def test_get_generates_a_labeled_tag_proc
    generated_proc = JsonTaggedLogger::TagFromSession.get(user_id: :uid)

    JsonTaggedLogger::TagFromSession.stub(:get_values_from_session, ["1234"], [@mock_request, :uid]) do
      output = generated_proc.call(@mock_request)

      expected_json = { user_id: "1234" }.to_json

      assert_equal expected_json, output
    end
  end

  def test_get_generates_a_multiple_tag_proc
    generated_proc = JsonTaggedLogger::TagFromSession.get(:user_id, :session_id)

    JsonTaggedLogger::TagFromSession.stub(
      :get_values_from_session, ["1234", "ABCD"], [@mock_request, [:user_id, :session_id]]
    ) do
      output = generated_proc.call(@mock_request)

      expected_json = { user_id: "1234", session_id: "ABCD" }.to_json

      assert_equal expected_json, output
    end
  end

  def test_get_generates_a_multiple_labeled_tag_proc
    generated_proc = JsonTaggedLogger::TagFromSession.get(user_id: :uid, session_id: :sid)

    JsonTaggedLogger::TagFromSession.stub(:get_values_from_session, ["1234", "ABCD"], [@mock_request, [:uid, :sid]]) do
      output = generated_proc.call(@mock_request)

      expected_json = { user_id: "1234", session_id: "ABCD" }.to_json

      assert_equal expected_json, output
    end
  end

  def test_get_generates_a_multiple_simple_and_labeled_tag_proc
    generated_proc = JsonTaggedLogger::TagFromSession.get(:tag1, :tag2, user_id: :uid, session_id: :sid)

    JsonTaggedLogger::TagFromSession.stub(
      :get_values_from_session, ["val1", "val2", "1234", "ABCD"], [@mock_request, [:tag1, :tag2, :uid, :sid]]
    ) do
      output = generated_proc.call(@mock_request)

      expected_json = { tag1: "val1", tag2: "val2", user_id: "1234", session_id: "ABCD" }.to_json

      assert_equal expected_json, output
    end
  end

  def test_get_when_all_session_values_are_missing
    generated_proc = JsonTaggedLogger::TagFromSession.get(:tag1, :tag2, user_id: :uid, session_id: :sid)

    JsonTaggedLogger::TagFromSession.stub(
      :get_values_from_session, [nil, nil, nil, nil], [@mock_request, [:tag1, :tag2, :uid, :sid]]
    ) do
      output = generated_proc.call(@mock_request)

      assert_equal "{}", output
    end
  end

  def test_get_mixture_of_present_and_missing_values
    generated_proc = JsonTaggedLogger::TagFromSession.get(:tag1, :tag2, user_id: :uid, session_id: :sid)

    JsonTaggedLogger::TagFromSession.stub(
      :get_values_from_session, ["val1", nil, "1234", nil], [@mock_request, [:tag1, :tag2, :uid, :sid]]
    ) do
      output = generated_proc.call(@mock_request)

      expected_json = { tag1: "val1", user_id: "1234" }.to_json

      assert_equal expected_json, output
    end
  end
end
