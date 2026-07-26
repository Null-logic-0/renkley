require "test_helper"

class PromptVisibilityAnalyzerServiceTest < ActiveSupport::TestCase
  FakeClient = Struct.new(:response, :grounded_sources) do
    def generate_json(_prompt) = response
    def generate_grounded(_prompt) = { text: "", sources: grounded_sources || [] }
  end

  test "filters the ranking down to brands we actually offered" do
    client = FakeClient.new({ "ranking" => [ "Kestrel", "Not A Real Brand", "Cadence" ], "note" => "Kestrel wins on price." })
    service = PromptVisibilityAnalyzerService.new(client: client)

    result = service.call("best project management tool", [ "Kestrel", "Cadence" ])

    assert_equal [ "Kestrel", "Cadence" ], result[:ranking]
    assert_equal "Kestrel wins on price.", result[:note]
  end

  test "extracts real citation domains from grounded search results" do
    client = FakeClient.new({ "ranking" => [ "Kestrel" ], "note" => nil },
      [ "https://www.g2.com/reviews/kestrel", "https://reddit.com/r/saas/thread" ])
    service = PromptVisibilityAnalyzerService.new(client: client)

    result = service.call("best project management tool", [ "Kestrel" ])

    assert_equal [ "g2.com", "reddit.com" ], result[:citation_domains]
  end

  test "returns an empty citation list when grounding is unavailable, without discarding the ranking" do
    client = Object.new
    def client.generate_json(_prompt) = { "ranking" => [ "Kestrel" ], "note" => nil }
    def client.generate_grounded(_prompt) = raise(GeminiClient::Error, "quota exceeded")

    service = PromptVisibilityAnalyzerService.new(client: client)

    result = service.call("best project management tool", [ "Kestrel" ])

    assert_equal [ "Kestrel" ], result[:ranking]
    assert_equal [], result[:citation_domains]
  end

  test "returns nil and does not raise when the client errors" do
    client = Object.new
    def client.generate_json(_prompt) = raise(GeminiClient::Error, "boom")

    service = PromptVisibilityAnalyzerService.new(client: client)

    assert_nil service.call("best project management tool", [ "Kestrel" ])
  end
end
