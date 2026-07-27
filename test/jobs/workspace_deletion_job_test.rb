require "test_helper"

class WorkspaceDeletionJobTest < ActiveJob::TestCase
  test "destroys the organization's users and the organization itself" do
    organization = Organization.create!(name: "Doomed Workspace")
    organization.users.create!(full_name: "Someone", email_address: "someone@doomed.example", password: "password1")

    assert_difference -> { User.count }, -1 do
      assert_difference -> { Organization.count }, -1 do
        WorkspaceDeletionJob.perform_now(organization)
      end
    end
  end
end
