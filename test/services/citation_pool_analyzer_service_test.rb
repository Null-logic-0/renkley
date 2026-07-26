require "test_helper"

class CitationPoolAnalyzerServiceTest < ActiveSupport::TestCase
  FakeClient = Struct.new(:response) do
    def generate_json(_prompt) = response
  end

  test "normalizes real, industry-relevant sites into domain/authority pairs" do
    client = FakeClient.new({ "sites" => [
      { "domain" => "https://www.capterra.com/reviews", "authority" => 88 },
      { "domain" => "reddit.com", "authority" => 500 }
    ] })
    service = CitationPoolAnalyzerService.new(client: client)

    result = service.call("Kestrel", "kestrel.com", [ "Loopwork" ])

    assert_equal [ { domain: "capterra.com", authority: 88 }, { domain: "reddit.com", authority: 99 } ], result
  end

  test "returns nil when the client errors, so callers fall back further" do
    client = Object.new
    def client.generate_json(_prompt) = raise(GeminiClient::Error, "boom")

    service = CitationPoolAnalyzerService.new(client: client)

    assert_nil service.call("Kestrel", "kestrel.com", [ "Loopwork" ])
  end

  test "returns nil when the model names no usable sites" do
    client = FakeClient.new({ "sites" => [] })
    service = CitationPoolAnalyzerService.new(client: client)

    assert_nil service.call("Kestrel", "kestrel.com", [ "Loopwork" ])
  end
end
