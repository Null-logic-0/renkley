class Scan < ApplicationRecord
  belongs_to :organization
  has_many :platform_snapshots, dependent: :destroy
  has_many :competitor_snapshots, dependent: :destroy
  has_many :prompt_results, dependent: :destroy

  enum :status, { pending: 0, running: 1, completed: 2, failed: 3 }, default: :pending

  scope :ordered, -> { order(:finished_at) }
  scope :completed_ordered, -> { completed.order(:finished_at) }

  def start!  = update!(status: :running, started_at: Time.current)
  def finish!(attrs, finished_at: Time.current) = update!(attrs.merge(status: :completed, finished_at: finished_at))
end
