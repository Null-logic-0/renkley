class Organization < ApplicationRecord
  has_many :users, dependent: :restrict_with_error
  has_many :companies, dependent: :destroy
  has_many :prompts, dependent: :destroy
  has_many :onboarding_tasks, dependent: :destroy

  enum :onboarding_status, { in_progress: 0, completed: 1, skipped: 2 }, default: :in_progress

  ONBOARDING_STEPS = %w[website competitors prompts setup].freeze


  validates :name, presence: true
  validates :slug, presence: true, uniqueness: true
  before_validation :generate_slug, on: :create


  def onboarding_step_name
    ONBOARDING_STEPS[onboarding_step - 1]
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
