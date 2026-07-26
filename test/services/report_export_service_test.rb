require "test_helper"

class ReportExportServiceTest < ActiveSupport::TestCase
  setup do
    @organization = organizations(:one)
    Report.seed_for!(@organization)
  end

  test "to_csv includes the report's own section" do
    report = @organization.reports.find_by(report_kind: "eye")

    csv = ReportExportService.new(report).to_csv

    assert_includes csv, "AI visibility score"
  end

  test "weekly_csv bundles every report into one file" do
    csv = ReportExportService.weekly_csv(@organization)

    assert_includes csv, "Weekly AI visibility export"
    @organization.reports.each { |r| assert_includes csv, r.name }
  end

  test "weekly_csv includes the past week's scan history" do
    scan = @organization.scans.create!(status: :pending)
    VisibilityScanService.new(@organization, scan, sequence: 1).call

    csv = ReportExportService.weekly_csv(@organization)

    assert_includes csv, scan.reload.overall_score.to_s
  end
end
