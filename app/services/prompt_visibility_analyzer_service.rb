
class PromptVisibilityAnalyzerService
  def initialize(client: GeminiClient.new)
    @client = client
  end


  def call(prompt_text, brand_names)
    result = @client.generate_json(build_prompt(prompt_text, brand_names))
    ranking = Array(result["ranking"]).map(&:to_s).select { |name| brand_names.include?(name) }
    { ranking: ranking, note: result["note"].to_s.presence, citation_domains: fetch_citation_domains(prompt_text) }
  rescue GeminiClient::Error => e
    Rails.logger.warn("[PromptVisibilityAnalyzerService] falling back to simulated ranking: #{e.message}")
    nil
  end

  private

  def fetch_citation_domains(prompt_text)
    @client.generate_grounded(prompt_text)[:sources].filter_map { |url| extract_domain(url) }
  rescue GeminiClient::Error => e
    Rails.logger.warn("[PromptVisibilityAnalyzerService] no real citations, grounding unavailable: #{e.message}")
    []
  end

  def extract_domain(url)
    URI.parse(url).host&.sub(/\Awww\./, "")
  rescue URI::InvalidURIError
    nil
  end

  def build_prompt(prompt_text, brand_names)
    <<~PROMPT
      You are simulating how an AI search assistant (like ChatGPT or Gemini) would answer a buyer's question, for competitive-analysis purposes only.

      Buyer's question: "#{prompt_text}"

      Candidate brands (in no particular order): #{brand_names.join(", ")}

      Rank only the brands from this exact list that a well-informed AI assistant would plausibly surface in answer to this question, best-recommended first. Omit any brand you have no real basis to include — an empty ranking is a valid answer if none apply.

      Respond with ONLY minified JSON matching exactly this shape, no markdown fencing, no extra prose:
      {"ranking": ["Brand", "Brand"], "note": "one sentence on why the top brand would be favored, naming the actual brands"}
    PROMPT
  end
end
