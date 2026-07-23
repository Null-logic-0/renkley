require "test_helper"

class OverviewControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    sign_in_as(@user)
  end

  test "should get index" do
    get overview_url
    assert_response :success
  end
end
