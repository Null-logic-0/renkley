class AiPlatform < ApplicationRecord
  validates :key, presence: true, uniqueness: true
  validates :name, presence: true

  scope :ordered, -> { order(:position) }
end
