# Users must belong to an organization (Organization#users is
# dependent: :restrict_with_error, a safety net against accidental
# destroys elsewhere) — so the deliberate "Delete workspace" flow removes
# the users first, then the organization itself, which cascades to every
# other association (companies, prompts, scans, citations,
# recommendations, reports, brand_aliases) via their existing
# dependent: :destroy.
class WorkspaceDeletionJob < ApplicationJob
  queue_as :default

  def perform(organization)
    organization.users.destroy_all
    organization.destroy
  end
end
