require 'minitest/autorun'

require 'json_tagged_logger'

class TagFromHeadersTest < Minitest::Test
  def setup
    @mock_request = Minitest::Mock.new
    @mock_request.expect :headers, { "Content-Type" => "application/json" }
  end

  def test_get_generates_a_proc_that_generates_expected_json
    generated_proc = JsonTaggedLogger::TagFromHeaders.get(:content_type, "Content-Type")

    output = generated_proc.call(@mock_request)

    @mock_request.verify

    expected_json = { content_type: "application/json" }.to_json

    assert_equal expected_json, output
  end
end
