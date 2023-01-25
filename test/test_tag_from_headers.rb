require 'minitest/autorun'

require 'json_tagged_logger'

class TagFromHeadersTest < Minitest::Test
  def setup
    @mock_request = Minitest::Mock.new
  end

  def test_get_generates_a_proc_from_a_single_header_key
    generated_proc = JsonTaggedLogger::TagFromHeaders.get("Content-Type")

    headers = {
      "Content-Type" => "application/json",
    }

    @mock_request.expect :headers, headers

    output = generated_proc.call(@mock_request)

    @mock_request.verify

    expected_json = {
      "Content-Type": "application/json",
    }.to_json

    assert_equal expected_json, output
  end

  def test_get_generates_a_proc_from_an_array_of_header_keys
    generated_proc = JsonTaggedLogger::TagFromHeaders.get(
      "Content-Type",
      "Accept-Language"
    )

    headers = {
      "Content-Type" => "application/json",
      "Accept-Language" => "en-US,en;q=0.5"
    }

    @mock_request.expect :headers, headers
    @mock_request.expect :headers, headers

    output = generated_proc.call(@mock_request)

    @mock_request.verify

    expected_json = {
      "Content-Type": "application/json",
      "Accept-Language": "en-US,en;q=0.5"
    }.to_json

    assert_equal expected_json, output
  end

  def test_get_generates_a_proc_that_generates_expected_json_for_single_labeled_header
    generated_proc = JsonTaggedLogger::TagFromHeaders.get(content_type: "Content-Type")

    @mock_request.expect :headers, { "Content-Type" => "application/json" }

    output = generated_proc.call(@mock_request)

    @mock_request.verify

    expected_json = { content_type: "application/json" }.to_json

    assert_equal expected_json, output
  end

  def test_get_generates_a_proc_that_generates_expected_json_for_multiple_labeled_headers
    generated_proc = JsonTaggedLogger::TagFromHeaders.get(
      content_type: "Content-Type",
      language: "Accept-Language"
    )

    headers = {
      "Content-Type" => "application/json",
      "Accept-Language" => "en-US,en;q=0.5"
    }

    @mock_request.expect :headers, headers
    @mock_request.expect :headers, headers

    output = generated_proc.call(@mock_request)

    @mock_request.verify

    expected_json = {
      content_type: "application/json",
      language: "en-US,en;q=0.5"
    }.to_json

    assert_equal expected_json, output
  end

  def test_get_generates_a_proc_for_labeled_and_unlabeled_header_keys
    generated_proc = JsonTaggedLogger::TagFromHeaders.get(
      "Content-Type",
      language: "Accept-Language",
      encoding: "Accept-Encoding"
    )

    headers = {
      "Content-Type" => "application/json",
      "Accept-Language" => "en-US,en;q=0.5",
      "Accept-Encoding" => "gzip, deflate, br"
    }

    @mock_request.expect :headers, headers
    @mock_request.expect :headers, headers
    @mock_request.expect :headers, headers

    output = generated_proc.call(@mock_request)

    @mock_request.verify

    expected_json = {
      "Content-Type": "application/json",
      language: "en-US,en;q=0.5",
      encoding: "gzip, deflate, br"
    }.to_json

    assert_equal expected_json, output
  end

  def test_get_when_all_headers_are_missing
    generated_proc = JsonTaggedLogger::TagFromHeaders.get(
      "Missing",
      language: "Also-Missing",
      encoding: "Stil-Missing"
    )

    headers = {
      "Content-Type" => "application/json",
      "Accept-Language" => "en-US,en;q=0.5",
      "Accept-Encoding" => "gzip, deflate, br"
    }

    @mock_request.expect :headers, headers
    @mock_request.expect :headers, headers
    @mock_request.expect :headers, headers

    output = generated_proc.call(@mock_request)

    @mock_request.verify

    assert_equal "{}", output
  end

  def test_get_mixture_of_present_and_missing_headers
    generated_proc = JsonTaggedLogger::TagFromHeaders.get(
      "Content-Type",
      "Missing",
      language: "Also-Missing",
      encoding: "Accept-Encoding"
    )

    headers = {
      "Content-Type" => "application/json",
      "Accept-Language" => "en-US,en;q=0.5",
      "Accept-Encoding" => "gzip, deflate, br"
    }

    @mock_request.expect :headers, headers
    @mock_request.expect :headers, headers
    @mock_request.expect :headers, headers
    @mock_request.expect :headers, headers

    output = generated_proc.call(@mock_request)

    @mock_request.verify

    expected_json = {
      "Content-Type": "application/json",
      encoding: "gzip, deflate, br"
    }.to_json

    assert_equal expected_json, output
  end
end
