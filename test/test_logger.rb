require 'minitest/autorun'

require 'json_tagged_logger'
require 'logger'
require 'stringio'

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
end
