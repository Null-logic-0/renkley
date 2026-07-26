require "test_helper"

class VisibilityScanServiceTest < ActiveSupport::TestCase
  setup do
    @organization = organizations(:one)
    @organization.companies.create!(name: "Rival", domain: "rival.com", kind: :competitor)
    @organization.prompts.create!(body: "Best tool for teams")
  end

  test "populates platform, competitor, and prompt results for a scan" do
    scan = @organization.scans.create!(status: :pending)

    VisibilityScanService.new(@organization, scan, sequence: 1).call

    assert scan.reload.completed?
    assert scan.overall_score.present?
    assert_equal AiPlatform.integrated.count * 2, scan.platform_snapshots.count # own + 1 competitor
    assert_equal 1, scan.competitor_snapshots.count
    assert_equal 1, scan.prompt_results.count
  end

  test "creates an owned company if none exists" do
    scan = @organization.scans.create!(status: :pending)

    assert_difference -> { @organization.companies.owned.count }, 1 do
      VisibilityScanService.new(@organization, scan, sequence: 1).call
    end
  end

  test "uses a real analyzer's ranking and attributes the result to Gemini" do
    scan = @organization.scans.create!(status: :pending)
    analyzer = Object.new
    def analyzer.call(_prompt_text, brand_names) = { ranking: [ brand_names.first ], note: "test note" }

    VisibilityScanService.new(@organization, scan, sequence: 1, analyzer: analyzer).call

    result = scan.prompt_results.first
    assert_equal ai_platforms(:gemini), result.ai_platform
    assert_equal 1, result.your_position
    assert result.winner_company.owned?
  end

  test "falls back to the simulation when the analyzer finds no match" do
    scan = @organization.scans.create!(status: :pending)
    analyzer = Object.new
    def analyzer.call(_prompt_text, _brand_names) = { ranking: [], note: nil }

    VisibilityScanService.new(@organization, scan, sequence: 1, analyzer: analyzer).call

    assert_not_nil scan.prompt_results.first.winner_company_id
  end

  test "builds citations from the analyzer's real grounded domains instead of the fabricated pool" do
    scan = @organization.scans.create!(status: :pending)
    analyzer = Object.new
    def analyzer.call(_prompt_text, brand_names) = { ranking: [ brand_names.first ], note: nil, citation_domains: [ "g2.com", "reddit.com" ] }

    VisibilityScanService.new(@organization, scan, sequence: 1, analyzer: analyzer).call

    domains = @organization.citations.pluck(:domain)
    assert_equal [ "g2.com", "reddit.com" ].sort, domains.sort
    assert @organization.citations.all? { |c| c.mentions_count == 1 }
  end

  test "falls back to the simulated citation pool when the analyzer returns no real domains" do
    scan = @organization.scans.create!(status: :pending)
    analyzer = Object.new
    def analyzer.call(_prompt_text, brand_names) = { ranking: [ brand_names.first ], note: nil, citation_domains: [] }

    VisibilityScanService.new(@organization, scan, sequence: 1, analyzer: analyzer).call

    assert_equal VisibilityScanService::CITATION_POOL.size + 1, @organization.citations.count
  end

  test "uses the AI-detected industry-relevant pool over the generic fallback when no real citations were found" do
    scan = @organization.scans.create!(status: :pending)
    analyzer = Object.new
    def analyzer.call(_prompt_text, brand_names) = { ranking: [ brand_names.first ], note: nil, citation_domains: [] }
    citation_pool_analyzer = Object.new
    def citation_pool_analyzer.call(_org_name, _domain, _competitor_names) = [ { domain: "capterra.com", authority: 88 }, { domain: "trustradius.com", authority: 80 } ]

    VisibilityScanService.new(@organization, scan, sequence: 1, analyzer: analyzer, citation_pool_analyzer: citation_pool_analyzer).call

    domains = @organization.citations.pluck(:domain)
    assert_includes domains, "capterra.com"
    assert_includes domains, "trustradius.com"
    assert_not_includes domains, "g2.com"
  end

  test "falls back to the generic pool when the AI-detected pool finds nothing" do
    scan = @organization.scans.create!(status: :pending)
    citation_pool_analyzer = Object.new
    def citation_pool_analyzer.call(_org_name, _domain, _competitor_names) = nil

    VisibilityScanService.new(@organization, scan, sequence: 1, citation_pool_analyzer: citation_pool_analyzer).call

    assert_equal VisibilityScanService::CITATION_POOL.size + 1, @organization.citations.count
  end
end
