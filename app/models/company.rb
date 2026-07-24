class Company < ApplicationRecord
  belongs_to :organization

  enum :kind, { competitor: 0, owned: 1 }, default: :competitor
  enum :source, { manual: 0, discovered: 1 }, default: :manual

  normalizes :domain, with: ->(d) {
    d.to_s.strip.downcase.sub(%r{\Ahttps?://}, "").sub(/\Awww\./, "").sub(%r{/.*\z}, "")
  }

  validates :name, presence: true
  validates :domain, presence: true, uniqueness: { scope: :organization_id }

  scope :ordered, -> { order(:position, :created_at) }
end
