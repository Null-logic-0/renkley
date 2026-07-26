class Prompt < ApplicationRecord
  belongs_to :organization
  has_many :prompt_results, dependent: :destroy

  enum :source, { manual: 0, seeded: 1 }, default: :manual
  enum :search_volume, { low: 0, medium: 1, high: 2 }, default: :medium

  normalizes :body, with: ->(b) { b.to_s.strip.squish }
  validates :body, presence: true

  scope :ordered, -> { order(:position, :created_at) }
end
