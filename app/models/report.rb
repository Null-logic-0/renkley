class Report < ApplicationRecord
  belongs_to :organization

  enum :tag, { automated: 0, on_demand: 1 }, default: :automated

  scope :ordered, -> { order(:created_at) }

  DEFAULTS = [
    { name: "Weekly AI Visibility Report", description: "Score, platform breakdown and week-over-week movement.",
      frequency: "Every Monday", report_kind: "eye", tag: :automated },
    { name: "Competitor Movement Report", description: "Who gained and lost AI share across tracked platforms.",
      frequency: "Bi-weekly", report_kind: "trophy", tag: :automated },
    { name: "SEO Opportunity Report", description: "Prioritized actions ranked by projected visibility impact.",
      frequency: "Monthly", report_kind: "clipboard_check", tag: :on_demand }
  ].freeze

  def self.seed_for!(organization)
    DEFAULTS.each do |attrs|
      organization.reports.find_or_create_by!(name: attrs[:name]) { |r| r.assign_attributes(attrs.except(:name)) }
    end
  end
end
