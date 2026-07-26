require "test_helper"

class GeminiClientTest < ActiveSupport::TestCase
  test "raises a clear error when no api key is configured" do
    error = assert_raises(GeminiClient::Error) { GeminiClient.new(api_key: nil) }
    assert_match(/not configured/, error.message)
  end

  test "defaults to the configured model when none is given" do
    client = GeminiClient.new(api_key: "test-key", model: nil)
    assert_equal "gemini-flash-latest", client.instance_variable_get(:@model)
  end
end
