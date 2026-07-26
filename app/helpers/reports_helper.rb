module ReportsHelper
  def report_tag_class(report)
    class_names("rk-ov-report-tag", "is-#{report.tag}")
  end
end
