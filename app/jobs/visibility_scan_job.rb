class VisibilityScanJob < ApplicationJob
  queue_as :default

  def perform(organization, scan)
    scan.start!
    broadcast_content(organization)

    sequence = organization.scans.completed.count + 1
    VisibilityScanService.new(organization, scan, sequence: sequence,
      analyzer: build_analyzer, citation_pool_analyzer: build_citation_pool_analyzer).call
    RecommendationGeneratorService.new(organization).call if organization.recommendations.none?

    broadcast_content(organization)
  rescue => e
    scan.update!(status: :failed)
    Rails.logger.error("[VisibilityScanJob] org=#{organization.id} failed: #{e.message}")
    raise
  end

  private

  # Falls back to nil (the seeded simulation) if Gemini isn't configured or
  # errors at construction, so a live scan still completes instead of failing.
  def build_analyzer
    PromptVisibilityAnalyzerService.new
  rescue GeminiClient::Error => e
    Rails.logger.warn("[VisibilityScanJob] Gemini unavailable, using simulated rankings: #{e.message}")
    nil
  end

  def build_citation_pool_analyzer
    CitationPoolAnalyzerService.new
  rescue GeminiClient::Error => e
    Rails.logger.warn("[VisibilityScanJob] Gemini unavailable, using generic citation pool: #{e.message}")
    nil
  end

  def broadcast_content(organization)
    Turbo::StreamsChannel.broadcast_replace_to(
      "organization_#{organization.id}_overview",
      target: "overview_content",
      partial: "overview/content",
      locals: { overview: OverviewPresenter.new(organization) }
    )
  end
end
