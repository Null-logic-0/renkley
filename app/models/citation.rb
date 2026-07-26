class Citation < ApplicationRecord
  belongs_to :organization
  belongs_to :last_scan, class_name: "Scan", optional: true

  enum :trend, { up: 0, down: 1 }, default: :up

  scope :ordered, -> { order(mentions_count: :desc) }
end
