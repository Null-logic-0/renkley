class Organization < ApplicationRecord
  has_many :users, dependent: :restrict_with_error
  has_many :companies, dependent: :destroy
  has_many :prompts, dependent: :destroy
  has_many :onboarding_tasks, dependent: :destroy
  has_many :scans, dependent: :destroy
  has_many :citations, dependent: :destroy
  has_many :recommendations, dependent: :destroy
  has_many :reports, dependent: :destroy
  has_many :brand_aliases, dependent: :destroy

  enum :onboarding_status, { in_progress: 0, completed: 1, skipped: 2 }, default: :in_progress
  enum :scan_frequency, { hourly: 0, daily: 1, weekly: 2 }, default: :daily

  ONBOARDING_STEPS = %w[website competitors prompts setup].freeze


  validates :name, presence: true
  validates :slug, presence: true, uniqueness: true
  before_validation :generate_slug, on: :create


  def onboarding_step_name
    ONBOARDING_STEPS[onboarding_step - 1]
  end

  # "all" (the default) means every integrated platform; anything else is
  # expected to be a real AiPlatform#key.
  def default_ai_platform_label
    return "All platforms" if default_ai_platform.blank? || default_ai_platform == "all"

    AiPlatform.find_by(key: default_ai_platform)&.name || "All platforms"
  end

  private

  def generate_slug
    return if slug.present?
    return if name.blank?
    base = name.parameterize
    candidate = base
    suffix = 1
    while Organization.exists?(slug: candidate)
      suffix += 1
      candidate = "#{base}-#{suffix}"
    end
    self.slug = candidate
  end
end
