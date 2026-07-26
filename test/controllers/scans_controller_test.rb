require "test_helper"

class ScansControllerTest < ActionDispatch::IntegrationTest
  setup do
    @organization = organizations(:one)
    @user = users(:one)
    sign_in_as(@user)
  end

  test "create enqueues a visibility scan job with a pending scan" do
    assert_enqueued_with(job: VisibilityScanJob) do
      assert_difference -> { @organization.scans.count }, 1 do
        post scans_path, as: :turbo_stream
      end
    end

    assert_equal "pending", @organization.scans.last.status
  end

  test "create redirects to overview for html requests" do
    post scans_path
    assert_redirected_to overview_path
  end
end
