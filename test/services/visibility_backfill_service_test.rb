require "test_helper"

class VisibilityBackfillServiceTest < ActiveSupport::TestCase
  test "seeds scan history and default reports once" do
    organization = organizations(:two)

    assert_difference -> { organization.scans.completed.count }, VisibilityBackfillService::SCAN_COUNT do
      VisibilityBackfillService.call(organization)
    end
    assert_equal Report::DEFAULTS.length, organization.reports.count
  end

  test "does nothing if scans already exist" do
    organization = organizations(:two)
    organization.scans.create!(status: :completed, finished_at: Time.current)

    assert_no_difference -> { organization.scans.count } do
      VisibilityBackfillService.call(organization)
    end
  end
end
