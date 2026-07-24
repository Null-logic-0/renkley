class Prompt < ApplicationRecord
  belongs_to :organization

  enum :source, { manual: 0, seeded: 1 }, default: :manual

  normalizes :body, with: ->(b) { b.to_s.strip.squish }
  validates :body, presence: true

  scope :ordered, -> { order(:position, :created_at) }
end
