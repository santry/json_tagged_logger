require 'minitest/autorun'

require 'json'
require 'json_tagged_logger'
require 'logger'
require 'stringio'

class FormatterTest < Minitest::Test
  def setup
    @output = StringIO.new
    @logger = JsonTaggedLogger::Logger.new(::Logger.new(@output))
  end

  %i(fatal error warn info debug).each do |level|
    define_method("test_#{level.to_s}_level") do
      @logger.send(level)

      result = JSON.parse(@output.string)
      assert_equal level.to_s.upcase, result["level"]
    end
  end

  def test_plain_text_message_is_put_in_msg
    message = "hello world"
    @logger.info(message)

    result = JSON.parse(@output.string)
    assert_equal message, result["msg"]
  end

  def test_json_message_is_merged_with_log_document
    message_hash = { key1: "val1", key2: "val2" }

    fixed_time = Time.now

    Time.stub(:now, fixed_time) do
      @logger.info(message_hash.to_json)

      expected_json = { level: "INFO", "time": fixed_time.utc.iso8601(3) }.merge(message_hash).to_json + "\n"

      assert_equal expected_json, @output.string
    end
  end

  def test_plain_tags_are_collected_under_tags_key
    @logger.tagged("tag1", "tag2").info

    results = JSON.parse(@output.string)

    assert_equal ["tag1", "tag2"], results["tags"]
  end

  def test_json_tags_are_merged_with_log_document
    tag1 = { key1: "val1" }.to_json
    tag2 = { key2: "val2" }.to_json

    @logger.tagged(tag1, tag2).info

    results = JSON.parse(@output.string)

    assert_equal "val1", results["key1"]
    assert_equal "val2", results["key2"]
  end

  def test_mixed_json_and_plain_tags_end_up_in_the_right_places
    tag1 = { key1: "val1" }.to_json
    tag2 = "tag2"
    tag3 = { key2: "val2" }.to_json
    tag4 = "tag4"

    @logger.tagged(tag1, tag2, tag3, tag4).info

    results = JSON.parse(@output.string)

    assert_equal [tag2, tag4], results["tags"]
    assert_equal "val1", results["key1"]
    assert_equal "val2", results["key2"]
  end

  def test_malformed_json_treated_as_plain_tag
    tag_missing_quotes_around_key = "{key1:\"val1\"}"

    @logger.tagged(tag_missing_quotes_around_key).info

    results = JSON.parse(@output.string)

    assert_equal [tag_missing_quotes_around_key], results["tags"]
  end

  def test_plain_message_with_all_tag_types
    tag1 = { key1: "val1" }.to_json
    tag2 = "tag2"
    tag3 = { key2: "val2" }.to_json
    tag4 = "tag4"
    tag_missing_quotes_around_key = "{key1:\"val1\"}"
    message = "hello world"

    @logger.tagged(tag1,
                   tag2,
                   tag3,
                   tag4,
                   tag_missing_quotes_around_key).
                   info(message)

    results = JSON.parse(@output.string)

    assert_equal message, results["msg"]
    assert_equal [tag2, tag4, tag_missing_quotes_around_key], results["tags"]
    assert_equal "val1", results["key1"]
    assert_equal "val2", results["key2"]
  end

  def test_json_message_with_all_tag_types
    tag1 = { key1: "val1" }.to_json
    tag2 = "tag2"
    tag3 = { key2: "val2" }.to_json
    tag4 = "tag4"
    tag_missing_quotes_around_key = "{key1:\"val1\"}"
    message_hash = { key3: "val3", key4: "val4" }

    @logger.tagged(tag1,
                   tag2,
                   tag3,
                   tag4,
                   tag_missing_quotes_around_key).
                   info(message_hash.to_json)

    results = JSON.parse(@output.string)

    assert_equal [tag2, tag4, tag_missing_quotes_around_key], results["tags"]
    assert_equal "val1", results["key1"]
    assert_equal "val2", results["key2"]
    assert_equal "val3", results["key3"]
    assert_equal "val4", results["key4"]
  end

  def test_tags_merged_with_tags_in_json_message
    message_hash = { key1: "val1", tags: ["tag1", "tag2"] }

    @logger.tagged("tag3", "tag4").info(message_hash.to_json)

    results = JSON.parse(@output.string)

    assert_equal "val1", results["key1"]
    assert_equal ["tag1", "tag2", "tag3", "tag4"], results["tags"]
  end

  def test_empty_json_tags
    message_hash = { key1: "val1", tags: ["tag1", "tag2"] }

    @logger.tagged("tag3", "tag4", "{}", "{}").info(message_hash.to_json)

    results = JSON.parse(@output.string)

    assert_equal "val1", results["key1"]
    assert_equal ["tag1", "tag2", "tag3", "tag4"], results["tags"]
  end

  def test_non_json_non_string_message
    @logger.info(42)

    results = JSON.parse(@output.string)

    assert_equal "42", results["msg"]
  end

  def test_non_json_non_string_tag
    non_json_non_string_tag = 42

    @logger.tagged(non_json_non_string_tag).info

    results = JSON.parse(@output.string)

    assert_equal ["42"], results["tags"]
  end

  def test_optional_pretty_printing
    @logger.formatter.pretty_print = true

    fixed_time = Time.now

    Time.stub(:now, fixed_time) do
      @logger.info("hello world")

      expected_output = <<~JSON
      {
        "level": "INFO",
        "time": "#{fixed_time.utc.iso8601(3)}",
        "msg": "hello world"
      }
      JSON

      assert_equal expected_output, @output.string
    end
  end

  def test_pretty_printing_set_by_initializer
    @logger = JsonTaggedLogger::Logger.new(::Logger.new(@output), pretty_print: true)

    fixed_time = Time.now

    Time.stub(:now, fixed_time) do
      @logger.info("hello world")

      expected_output = <<~JSON
      {
        "level": "INFO",
        "time": "#{fixed_time.utc.iso8601(3)}",
        "msg": "hello world"
      }
      JSON

      assert_equal expected_output, @output.string
    end
  end
end
