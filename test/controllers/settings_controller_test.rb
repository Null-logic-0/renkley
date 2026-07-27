require "test_helper"

class SettingsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @organization = organizations(:one)
    @user = users(:one)
    sign_in_as(@user)
  end

  test "should get show" do
    get settings_path
    assert_response :success
  end

  test "update saves workspace and brand tracking fields" do
    patch settings_path, params: { organization: {
      name: "Renamed Workspace", website_url: "renamed.com",
      category: "Project management software", default_ai_platform: "gemini", scan_frequency: "hourly"
    } }

    assert_redirected_to settings_path
    @organization.reload
    assert_equal "Renamed Workspace", @organization.name
    assert_equal "renamed.com", @organization.website_url
    assert_equal "Project management software", @organization.category
    assert_equal "gemini", @organization.default_ai_platform
    assert_equal "hourly", @organization.scan_frequency
  end

  test "update rejects a blank workspace name" do
    patch settings_path, params: { organization: { name: "" } }

    assert_response :unprocessable_entity
    assert_not_equal "", @organization.reload.name
  end

  test "update changes the password when a new one is submitted alongside workspace fields" do
    patch settings_path, params: {
      organization: { name: @organization.name },
      current_password: "password", password: "newpassword1", password_confirmation: "newpassword1"
    }

    assert_redirected_to settings_path
    assert @user.reload.authenticate("newpassword1")
  end

  test "update rejects an incorrect current password and leaves it unchanged" do
    patch settings_path, params: {
      organization: { name: @organization.name },
      current_password: "wrong", password: "newpassword1", password_confirmation: "newpassword1"
    }

    assert_response :unprocessable_entity
    assert @user.reload.authenticate("password")
  end

  test "update does not touch the password when the field is left blank" do
    patch settings_path, params: { organization: { name: @organization.name } }

    assert_redirected_to settings_path
    assert @user.reload.authenticate("password")
  end

  test "destroy logs the user out and enqueues the workspace deletion job" do
    assert_enqueued_with(job: WorkspaceDeletionJob, args: [ @organization ]) do
      delete settings_path
    end

    assert_redirected_to sign_in_path

    get overview_path
    assert_redirected_to new_session_path
  end
end
