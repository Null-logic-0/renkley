# Asks Gemini which real, well-known websites are likely to be cited when an
# AI search assistant discusses this organization's actual industry — used as
# the citation fallback instead of one fixed generic SaaS-review pool for
# every organization, when the per-prompt grounded citations found nothing
# real yet (e.g. the search-grounding quota is exhausted but plain
# generation still works). This is a plain (non-grounded) call, so it isn't
# gated by that same stricter quota.
class CitationPoolAnalyzerService
  def initialize(client: GeminiClient.new)
    @client = client
  end

  # organization_name/website: the org being scanned; competitor_names: real
  # tracked competitor Company names, for context only.
  # Returns [{ domain:, authority: }, ...] (real, relevant domains) or nil if
  # the call failed or returned nothing usable — callers should fall back
  # further to the generic pool.
  def call(organization_name, website, competitor_names)
    result = @client.generate_json(build_prompt(organization_name, website, competitor_names))
    Array(result["sites"]).filter_map { |entry| normalize(entry) }.presence
  rescue GeminiClient::Error => e
    Rails.logger.warn("[CitationPoolAnalyzerService] falling back to generic pool: #{e.message}")
    nil
  end

  private

  def normalize(entry)
    domain = entry["domain"].to_s.strip.downcase.delete_prefix("https://").delete_prefix("http://").delete_prefix("www.").split("/").first
    return nil if domain.blank?

    { domain: domain, authority: entry["authority"].to_i.clamp(40, 99) }
  end

  def build_prompt(organization_name, website, competitor_names)
    <<~PROMPT
      You are helping model which real websites an AI search assistant (like ChatGPT or Gemini) would
      plausibly cite as sources when answering questions about "#{organization_name}"#{" (#{website})" if website.present?} and its
      competitors: #{competitor_names.join(", ")}.

      Name 5-6 REAL, well-known websites specific to this industry — review sites, community forums,
      comparison sites, or trade publications an AI would actually cite for this space, not a generic
      unrelated list. For each, estimate a domain authority score from 40-99.

      Respond with ONLY minified JSON matching exactly this shape, no markdown fencing, no extra prose:
      {"sites": [{"domain": "example.com", "authority": 85}]}
    PROMPT
  end
end
