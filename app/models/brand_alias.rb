class BrandAlias < ApplicationRecord
  belongs_to :organization

  validates :name, presence: true, uniqueness: { scope: :organization_id }

  scope :ordered, -> { order(:created_at) }
end
