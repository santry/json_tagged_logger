# frozen_string_literal: true

require "minitest/autorun"

require "json_tagged_logger"
require "logger"
require "stringio"

class LoggerTest < Minitest::Test
  def setup
    @output = StringIO.new
    @logger = JsonTaggedLogger::Logger.new(::Logger.new(@output))
  end

  def test_new_adds_formatter_to_logger
    assert @logger.formatter.is_a?(JsonTaggedLogger::Formatter)
  end

  def test_new_creates_tagged_logging_logger
    assert @logger.respond_to?(:tagged)
  end

  def test_new_accepts_pretty_print_option_for_formatter
    @logger = JsonTaggedLogger::Logger.new(::Logger.new(@output), pretty_print: true)
    assert @logger.formatter.pretty_print
  end
end
