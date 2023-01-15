require 'minitest/autorun'
require 'json_tagged_logger'

class FormatterTest < Minitest::Test
  def test_foo
    assert_equal "hello world", "hello world"
  end
end
