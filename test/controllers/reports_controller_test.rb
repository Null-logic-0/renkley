require "test_helper"

class ReportsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @organization = organizations(:one)
    @user = users(:one)
    sign_in_as(@user)
    Report.seed_for!(@organization)
  end

  test "should get index" do
    get reports_url
    assert_response :success
  end

  test "create adds a custom report and redirects to the reports index" do
    assert_difference -> { @organization.reports.count }, 1 do
      post reports_url
    end

    assert_redirected_to reports_url
  end

  test "download returns a CSV file for a report" do
    report = @organization.reports.first

    get download_report_url(report)

    assert_response :success
    assert_equal "text/csv", response.media_type
  end

  test "cannot download another organization's report" do
    other_organization = Organization.create!(name: "Other Org")
    other_report = other_organization.reports.create!(name: "Not yours", description: "x", frequency: "x", report_kind: "eye")

    get download_report_url(other_report)

    assert_response :not_found
  end

  test "download_all returns a single combined CSV covering every report" do
    get download_all_reports_url

    assert_response :success
    assert_equal "text/csv", response.media_type
    @organization.reports.each { |r| assert_includes response.body, r.name }
  end
end
