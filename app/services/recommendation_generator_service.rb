class RecommendationGeneratorService
  Template = Struct.new(:category, :effort, :priority, :impact, :build, keyword_init: true)

  TEMPLATES = [
    Template.new(category: "Content", effort: :medium_effort, priority: :high, impact: 9, build: ->(ctx) {
      { title: "Publish a “#{ctx[:org_name]} vs #{ctx[:top_rival]}” comparison page",
        rationale: "#{ctx[:top_rival]} wins #{ctx[:lost_to_top_rival]} prompt#{"s" unless ctx[:lost_to_top_rival] == 1} you don’t currently rank for." } }),
    Template.new(category: "Docs", effort: :medium_effort, priority: :high, impact: 8, build: ->(ctx) {
      { title: "Expand documentation for your most-searched topics",
        rationale: "AI models cite documentation heavily; yours currently earns #{ctx[:docs_share]}% share of those citations." } }),
    Template.new(category: "Authority", effort: :hard, priority: :medium, impact: 7, build: ->(ctx) {
      { title: "Earn citations on #{ctx[:weakest_source]}",
        rationale: "#{100 - ctx[:weakest_source_share]}% of citations there go to competitors — you're thin on that source." } }),
    Template.new(category: "Technical", effort: :easy, priority: :medium, impact: 5, build: ->(_ctx) {
      { title: "Add structured data to product pages",
        rationale: "Improves how AI engines parse your features and pricing." } }),
    Template.new(category: "Content", effort: :easy, priority: :low, impact: 4, build: ->(ctx) {
      if ctx[:unranked_prompt]
        { title: "Close the gap on “#{ctx[:unranked_prompt]}”",
          rationale: "You aren't surfacing at all for this prompt; #{ctx[:unranked_prompt_winner]} currently owns it." }
      else
        { title: "Refresh pricing page copy for AI clarity",
          rationale: "Ambiguous pricing pages make it harder for AI engines to recommend you on price-sensitive prompts." }
      end
    })
  ].freeze

  def initialize(organization)
    @organization = organization
  end

  def call
    context = build_context

    @organization.recommendations.destroy_all
    TEMPLATES.each_with_index do |template, index|
      built = template.build.call(context)
      @organization.recommendations.create!(
        title: built[:title], rationale: built[:rationale],
        priority: template.priority, category: template.category, effort: template.effort,
        impact_score: template.impact, position: index
      )
    end
  end

  private

  def build_context
    latest_scan = @organization.scans.completed_ordered.last
    own_company = @organization.companies.owned.first
    competitors = @organization.companies.competitor.ordered.to_a

    top_rival = top_rival_for(latest_scan, competitors)
    citation = @organization.citations.order(your_share_pct: :asc).first
    unranked_result = latest_scan&.prompt_results&.where(your_position: nil)&.first

    {
      org_name: @organization.name,
      top_rival: top_rival&.name || competitors.first&.name || "your top competitor",
      lost_to_top_rival: lost_prompt_count(latest_scan, own_company, top_rival),
      docs_share: citation&.your_share_pct || 40,
      weakest_source: citation&.domain || "review sites",
      weakest_source_share: citation&.your_share_pct || 35,
      unranked_prompt: unranked_result&.prompt&.body,
      unranked_prompt_winner: unranked_result&.winner_company&.name
    }
  end

  def top_rival_for(scan, competitors)
    return competitors.first if scan.nil?

    snapshot = scan.competitor_snapshots.order(score: :desc).first
    snapshot ? snapshot.company : competitors.first
  end

  def lost_prompt_count(scan, own_company, top_rival)
    return 0 unless scan && own_company && top_rival

    scan.prompt_results.where(winner_company_id: top_rival.id).count
  end
end
