class Recommendation < ApplicationRecord
  belongs_to :organization

  enum :priority, { low: 0, medium: 1, high: 2 }
  enum :effort, { easy: 0, medium_effort: 1, hard: 2 }
  enum :status, { pending: 0, applied: 1, dismissed: 2 }, default: :pending

  scope :ordered, -> { order(:position) }
  scope :active, -> { where.not(status: :dismissed) }

  def impact_score_out_of_ten
    impact_score
  end
end
