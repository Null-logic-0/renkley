class VisibilityBackfillService
  SCAN_COUNT = 8

  def self.call(organization)
    return if organization.scans.exists?

    SCAN_COUNT.times do |i|
      sequence = i + 1
      finished_at = (SCAN_COUNT - sequence).weeks.ago
      scan = organization.scans.create!(status: :pending, started_at: finished_at)
      VisibilityScanService.new(organization, scan, sequence: sequence, finished_at: finished_at).call
    end

    RecommendationGeneratorService.new(organization).call
    Report.seed_for!(organization)
  end
end
