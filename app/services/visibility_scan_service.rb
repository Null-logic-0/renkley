class VisibilityScanService
  CITATION_POOL = [
    { domain: "g2.com", authority: 93 },
    { domain: "reddit.com", authority: 91 },
    { domain: "capterra.com", authority: 88 },
    { domain: "producthunt.com", authority: 82 },
    { domain: "techradar.com", authority: 86 }
  ].freeze


  def initialize(organization, scan, sequence:, finished_at: Time.current, analyzer: nil, citation_pool_analyzer: nil)
    @organization = organization
    @scan = scan
    @sequence = sequence
    @finished_at = finished_at
    @analyzer = analyzer
    @citation_pool_analyzer = citation_pool_analyzer
    @rng = Random.new(organization.id * 977 + sequence)
    @real_citations = Hash.new { |h, k| h[k] = { count: 0, wins: 0 } }
  end

  def call
    own_company = find_or_create_owned_company
    competitors = @organization.companies.competitor.ordered.to_a
    platforms = AiPlatform.integrated.ordered.to_a
    prompts = @organization.prompts.ordered.to_a

    own_score = drifted_score(seed_base: 58 + (@organization.id % 15), pace: 2.2)
    competitor_scores = competitors.index_with { |c| drifted_score(seed_base: 45 + (c.id % 45), pace: pace_for(c)) }

    platform_snapshots = build_platform_snapshots(platforms, prompts.size, own_company, own_score, competitors, competitor_scores)
    competitor_snapshots = build_competitor_snapshots(competitors, competitor_scores)
    prompt_results = build_prompt_results(prompts, platforms, own_company, competitors, own_score, competitor_scores)
    citation_rows = build_citations(own_company, own_score, competitors)

    mentions_total = platform_snapshots.select { |p| p[:company_id].nil? }.sum { |p| p[:mentions_count] }
    citation_share = citation_rows.empty? ? 0 : (citation_rows.sum { |c| c[:your_share_pct] } / citation_rows.size.to_f).round
    rank = 1 + competitor_scores.values.count { |s| s > own_score }

    ActiveRecord::Base.transaction do
      platform_snapshots.each { |attrs| @scan.platform_snapshots.create!(attrs) }
      competitor_snapshots.each { |attrs| @scan.competitor_snapshots.create!(attrs) }
      prompt_results.each { |attrs| @scan.prompt_results.create!(attrs) }
      citation_rows.each { |attrs| upsert_citation(attrs) }

      @scan.finish!({
        overall_score: own_score,
        ranking_position: rank,
        mentions_count: mentions_total,
        citation_share_pct: citation_share
      }, finished_at: @finished_at)
    end

    @scan
  end

  private

  def find_or_create_owned_company
    @organization.companies.owned.first || @organization.companies.create!(
      name: @organization.name,
      domain: @organization.website_url.presence || "#{@organization.slug}.com",
      kind: :owned, source: :discovered, position: -1
    )
  end

  def pace_for(company)
    ((company.id * 13) % 5) - 2.0
  end

  def drifted_score(seed_base:, pace:)
    score = seed_base + (pace * @sequence) + @rng.rand(-3.0..3.0)
    score.round.clamp(20, 97)
  end

  PLATFORM_OFFSETS = { "chatgpt" => 4, "claude" => -2, "google_ai" => -8, "gemini" => -14, "perplexity" => -10 }.freeze


  def build_platform_snapshots(platforms, prompt_count, own_company, own_score, competitors, competitor_scores)
    entrants = [ [ own_company, own_score ] ] + competitors.map { |c| [ c, competitor_scores[c] ] }

    entrants.flat_map do |company, score|
      platforms.map do |platform|
        offset = PLATFORM_OFFSETS.fetch(platform.key, 0)
        visibility = (score + offset + @rng.rand(-4..4)).round.clamp(5, 99)
        mentions = ((visibility / 100.0) * (40 + prompt_count * 35) + @rng.rand(0..20)).round
        rank_number = (6 - (visibility / 17)).clamp(1, 5)
        { ai_platform_id: platform.id, company_id: (company == own_company ? nil : company.id),
          visibility_pct: visibility, mentions_count: mentions, rank_label: "##{rank_number}" }
      end
    end
  end

  def build_competitor_snapshots(competitors, competitor_scores)
    competitors.map do |c|
      score = competitor_scores[c]
      { company_id: c.id, score: score, citations_count: (score * @rng.rand(0.4..0.8)).round }
    end
  end

  def build_prompt_results(prompts, platforms, own_company, competitors, own_score, competitor_scores)
    return [] if prompts.empty? || platforms.empty?

    gemini_platform = platforms.find { |p| p.key == "gemini" }
    entrants_by_name = ([ own_company ] + competitors).index_by(&:name)
    brand_names = entrants_by_name.keys

    prompts.map do |prompt|
      ai_result = @analyzer&.call(prompt.body, brand_names)

      if ai_result && ai_result[:ranking].present? && gemini_platform
        ranked = ai_result[:ranking].map { |name| entrants_by_name[name] }.compact
        platform = gemini_platform
        record_real_citations(ai_result[:citation_domains], won: ranked.first == own_company)
      else
        platform = platforms[prompt.id % platforms.size]
        entrants = [ [ own_company, own_score ] ] + competitors.map { |c| [ c, competitor_scores[c] ] }
        ranked = entrants.map { |co, score| [ co, score + @rng.rand(-15.0..15.0) ] }
                         .sort_by { |_, jittered| -jittered }
                         .map(&:first)
        ranked = ranked.first([ ranked.size, @rng.rand(2..entrants.size) ].min)
      end

      your_index = ranked.index(own_company)
      winner = ranked.first
      top_competitor = ranked.find { |co| co != own_company }

      { prompt_id: prompt.id, ai_platform_id: platform.id,
        your_position: your_index && your_index + 1,
        winner_company_id: winner.id,
        top_competitor_company_id: top_competitor&.id }
    end
  end


  # Three tiers, most-real first: (1) real per-prompt citations from Gemini's
  # search-grounding metadata, (2) an AI-detected pool of websites actually
  # relevant to this organization's industry (still simulated mention counts,
  # but a real, org-specific domain set instead of one fixed generic list
  # for every organization), (3) the fabricated generic pool, for historical
  # backfill and whenever Gemini isn't reachable at all.
  def build_citations(own_company, own_score, competitors)
    return real_citation_rows if @real_citations.any?

    domains = ai_detected_pool(own_company, competitors) + [ { domain: "#{own_company.domain}/docs", authority: 64 } ]
    domains.map do |entry|
      mentions = (entry[:authority] * @rng.rand(0.8..1.6)).round
      your_share = entry[:domain].start_with?(own_company.domain) ? 100 : (own_score / 2.2 + @rng.rand(-8..8)).round.clamp(5, 90)
      { domain: entry[:domain], authority_score: entry[:authority], mentions_count: mentions,
        your_share_pct: your_share, competitor_share_pct: 100 - your_share }
    end
  end

  def ai_detected_pool(own_company, competitors)
    return CITATION_POOL unless @citation_pool_analyzer

    @citation_pool_analyzer.call(own_company.name, own_company.domain, competitors.map(&:name)) || CITATION_POOL
  end

  def record_real_citations(domains, won:)
    Array(domains).each do |domain|
      entry = @real_citations[domain]
      entry[:count] += 1
      entry[:wins] += 1 if won
    end
  end

  def real_citation_rows
    max_count = @real_citations.values.map { |v| v[:count] }.max.to_f
    @real_citations.map do |domain, stats|
      authority = (55 + (stats[:count] / max_count) * 40).round.clamp(50, 99)
      your_share = ((stats[:wins].to_f / stats[:count]) * 100).round.clamp(5, 95)
      { domain: domain, authority_score: authority, mentions_count: stats[:count],
        your_share_pct: your_share, competitor_share_pct: 100 - your_share }
    end.sort_by { |c| -c[:mentions_count] }
  end

  def upsert_citation(attrs)
    citation = @organization.citations.find_or_initialize_by(domain: attrs[:domain])
    trend = citation.persisted? && attrs[:mentions_count] < citation.mentions_count ? :down : :up
    citation.update!(attrs.merge(trend: trend, last_scan: @scan))
  end
end
