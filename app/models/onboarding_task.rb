class OnboardingTask < ApplicationRecord
  belongs_to :organization

  enum :status, { pending: 0, in_progress: 1, done: 2, failed: 3 }, default: :pending

  STAGES = [
    { key: "fetch_profile",          label: "Fetching your site profile" },
    { key: "query_platforms",        label: "Querying AI platforms" },
    { key: "benchmark_competitors",  label: "Benchmarking competitors" },
    { key: "build_dashboard",        label: "Building your dashboard" }
  ].freeze

  scope :ordered, -> { order(:position) }

  def self.seed_for!(organization)
    STAGES.each_with_index do |stage, index|
      organization.onboarding_tasks.find_or_create_by!(key: stage[:key]) do |t|
        t.label = stage[:label]
        t.position = index
      end
    end
  end

  def start!  = update!(status: :in_progress, started_at: Time.current)
  def finish! = update!(status: :done, finished_at: Time.current)
  def fail!   = update!(status: :failed, finished_at: Time.current)
end
