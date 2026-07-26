class ReportsController < ApplicationController
  include EnforcesOnboarding
  layout "dashboard"

  before_action :set_report, only: :download

  def index
    @reports = Current.organization.reports.ordered
  end

  def create
    Current.organization.reports.create!(
      name: "Custom report ##{Current.organization.reports.count + 1}",
      description: "A custom report you can configure further from its settings.",
      frequency: "On demand", report_kind: "file_text", tag: :on_demand
    )

    redirect_to reports_path, notice: "New report created."
  end

  def download
    export = ReportExportService.new(@report)
    send_data export.to_csv, filename: export.filename, type: "text/csv"
  end

  def download_all
    send_data ReportExportService.weekly_csv(Current.organization),
              filename: ReportExportService.weekly_filename, type: "text/csv"
  end

  private

  def set_report
    @report = Current.organization.reports.find(params[:id])
  end
end
