require "csv"
class ReportExportService
  def self.weekly_csv(organization)
    scans = organization.scans.completed_ordered.where(finished_at: 1.week.ago..)

    CSV.generate do |csv|
      csv << [ "Weekly AI visibility export", weekly_range_label ]
      csv << []
      csv << [ "Date", "Score", "Ranking position", "AI mentions", "Citation share %" ]
      scans.each { |s| csv << [ s.finished_at.to_date, s.overall_score, s.ranking_position, s.mentions_count, s.citation_share_pct ] }

      organization.reports.ordered.each do |report|
        csv << []
        csv << [ report.name ]
        new(report).append_rows(csv)
      end
    end
  end

  def self.weekly_filename
    "weekly-reports-#{1.week.ago.to_date.iso8601}-to-#{Date.current.iso8601}.csv"
  end

  def self.weekly_range_label
    "#{1.week.ago.to_date.iso8601} to #{Date.current.iso8601}"
  end

  def initialize(report)
    @report = report
    @organization = report.organization
    @presenter = OverviewPresenter.new(@organization)
  end

  def filename
    "#{@report.name.parameterize}-#{Date.current.iso8601}.csv"
  end

  def to_csv
    CSV.generate { |csv| append_rows(csv) }
  end

  def append_rows(csv)
    case @report.report_kind
    when "eye" then append_visibility_rows(csv)
    when "trophy" then append_competitor_rows(csv)
    when "clipboard_check" then append_recommendations_rows(csv)
    else append_summary_rows(csv)
    end
  end

  private

  def append_visibility_rows(csv)
    csv << [ "Metric", "Value" ]
    csv << [ "AI visibility score", @presenter.score ]
    csv << [ "Grade", @presenter.score_grade ]
    csv << [ "Ranking position", @presenter.latest_scan&.ranking_position ]
    csv << [ "AI mentions", @presenter.latest_scan&.mentions_count ]
    csv << [ "Citation share %", @presenter.latest_scan&.citation_share_pct ]
    csv << []
    csv << [ "Platform", "Visibility %", "Rank", "Mentions" ]
    @presenter.platforms.each { |p| csv << [ p[:name], p[:vis], p[:rank], p[:mentions] ] }
  end

  def append_competitor_rows(csv)
    csv << [ "Brand", "AI score", "Citations", "Change %" ]
    @presenter.competitors.each { |c| csv << [ c[:brand], c[:score], c[:cites], c[:delta] ] }
  end

  def append_recommendations_rows(csv)
    csv << [ "Title", "Priority", "Effort", "Impact (/10)", "Category" ]
    @organization.recommendations.ordered.each do |r|
      csv << [ r.title, r.priority, r.effort, r.impact_score_out_of_ten, r.category ]
    end
  end

  def append_summary_rows(csv)
    csv << [ "Metric", "Value" ]
    csv << [ "AI visibility score", @presenter.score ]
    csv << [ "Ranking position", @presenter.latest_scan&.ranking_position ]
    csv << [ "AI mentions", @presenter.latest_scan&.mentions_count ]
    csv << [ "Citation share %", @presenter.latest_scan&.citation_share_pct ]
  end
end
