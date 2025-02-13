# frozen_string_literal: true

require "minitest/autorun"

require "json_tagged_logger"

class LogTagsConfigTest < Minitest::Test
  def setup
    @mock_request = Minitest::Mock.new
    @request_id = "1234"
  end

  def test_generate_for_string_returns_simple_tag
    config = JsonTaggedLogger::LogTagsConfig.generate("tag")

    assert_equal ["tag"], config
  end

  def test_generate_for_symbol_returns_proc_that_builds_json
    config = JsonTaggedLogger::LogTagsConfig.generate(:request_id)

    assert config.size == 1
    assert config[0].is_a?(Proc)
    assert config[0].arity == 1

    @mock_request.expect :request_id, @request_id

    tag_output = config[0].call(@mock_request)

    @mock_request.verify

    expected_json = { request_id: @request_id }.to_json

    assert_equal expected_json, tag_output
  end

  def test_generate_tag_config_for_proc
    request_id_proc = ->(request) { { request_id: request.request_id }.to_json }

    config = JsonTaggedLogger::LogTagsConfig.generate(request_id_proc)

    assert config.size == 1
    assert config[0] == request_id_proc

    @mock_request.expect :request_id, @request_id

    tag_output = config[0].call(@mock_request)

    @mock_request.verify

    expected_json = { request_id: @request_id }.to_json

    assert_equal expected_json, tag_output
  end

  def test_mixed_string_symbol_and_proc
    request_id_proc = ->(request) { { request_id: request.request_id }.to_json }

    config = JsonTaggedLogger::LogTagsConfig.generate("tag", :request_id, request_id_proc)

    assert_equal 3, config.size
    assert_equal "tag", config[0]
    assert_equal 1, config[1].arity
    assert_equal 1, config[2].arity

    config[1..].each do |t|
      @mock_request.expect :request_id, @request_id

      tag_output = t.call(@mock_request)

      @mock_request.verify

      expected_json = { request_id: @request_id }.to_json

      assert_equal expected_json, tag_output
    end
  end

  def test_raises_on_symbol_for_unknown_request_method
    assert_raises(ArgumentError) { JsonTaggedLogger::LogTagsConfig.generate(:unknown_method) }
  end

  def test_raises_on_proc_with_wrong_arity
    assert_raises(ArgumentError) { JsonTaggedLogger::LogTagsConfig.generate(-> { "0 arity" }) }
    assert_raises(ArgumentError) { JsonTaggedLogger::LogTagsConfig.generate(->(_a, _b) { "arity > 1" }) }
  end
end
