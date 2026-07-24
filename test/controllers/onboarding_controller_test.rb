require "test_helper"

class OnboardingControllerTest < ActionDispatch::IntegrationTest
  setup do
    @organization = Organization.create!(name: "Fresh Org")
    @user = User.create!(
      email_address: "fresh@example.com", full_name: "Fresh Person",
      password: "password123", confirmed_at: Time.current, organization: @organization
    )
    sign_in_as(@user)
  end

  test "show renders the website step for a fresh organization" do
    get onboarding_path
    assert_response :success
    assert_select "h1", /find your competitors/
  end

  test "show renders the competitors step" do
    @organization.update!(onboarding_step: 2)

    get onboarding_path
    assert_response :success
    assert_select "h1", /found some competitors/
  end

  test "show renders the setup step" do
    @organization.update!(onboarding_step: 4)

    get onboarding_path
    assert_response :success
    assert_select "h1", /setting up your dashboard/
  end

  test "redirects to overview once onboarding is completed" do
    @organization.update!(onboarding_status: :completed)

    get onboarding_path
    assert_redirected_to overview_path
  end

  test "redirects to overview once onboarding is skipped" do
    @organization.update!(onboarding_status: :skipped)

    get onboarding_path
    assert_redirected_to overview_path
  end

  test "scan requires a website url" do
    post scan_onboarding_path, params: { website_url: "" }

    assert_redirected_to onboarding_path
    assert_equal 1, @organization.reload.onboarding_step
  end

  test "scan saves the url, enqueues discovery, and advances to competitors" do
    assert_enqueued_with(job: CompetitorDiscoveryJob, args: [ @organization ]) do
      post scan_onboarding_path, params: { website_url: "kestrel.io" }
    end

    @organization.reload
    assert_equal "kestrel.io", @organization.website_url
    assert_equal 2, @organization.onboarding_step
    assert_redirected_to onboarding_path
  end

  test "next_step advances the step" do
    @organization.update!(onboarding_step: 2)

    post next_step_onboarding_path

    assert_equal 3, @organization.reload.onboarding_step
    assert_redirected_to onboarding_path
  end

  test "back decrements the step" do
    @organization.update!(onboarding_step: 3)

    post back_onboarding_path

    assert_equal 2, @organization.reload.onboarding_step
  end

  test "back does not go below step 1" do
    post back_onboarding_path

    assert_equal 1, @organization.reload.onboarding_step
  end

  test "finish seeds onboarding tasks, enqueues setup, and advances to setup" do
    @organization.update!(onboarding_step: 3)

    assert_enqueued_with(job: OnboardingSetupJob, args: [ @organization ]) do
      post finish_onboarding_path
    end

    @organization.reload
    assert_equal 4, @organization.onboarding_step
    assert_equal OnboardingTask::STAGES.length, @organization.onboarding_tasks.count
  end

  test "skip marks onboarding skipped and redirects to overview" do
    post skip_onboarding_path

    assert @organization.reload.skipped?
    assert_redirected_to overview_path
  end
end
