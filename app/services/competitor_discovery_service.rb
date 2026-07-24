class CompetitorDiscoveryService
  # Real discovery (crawling/AI-based analysis of the given site) isn't wired
  # up yet — this seeds a believable, deterministic result set so the rest of
  # onboarding has real records to work with instead of an empty list. Same
  # fictional companies the design mockup itself uses as placeholder data.
  SEEDED_COMPETITORS = [
    { name: "Cadence", domain: "cadence.io" },
    { name: "Loopwork", domain: "loopwork.com" },
    { name: "Trellix", domain: "trellix.app" },
    { name: "Pilot", domain: "pilothq.co" },
    { name: "Beacon", domain: "beacon.so" }
  ].freeze

  def initialize(website_url)
    @website_url = website_url
  end

  def call
    SEEDED_COMPETITORS.reject { |c| c[:domain] == normalized_domain }
  end

  private

  def normalized_domain
    @website_url.to_s.strip.downcase.sub(%r{\Ahttps?://}, "").sub(/\Awww\./, "").sub(%r{/.*\z}, "")
  end
end
