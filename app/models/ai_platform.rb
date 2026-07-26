class AiPlatform < ApplicationRecord
  has_many :platform_snapshots, dependent: :destroy
  has_many :prompt_results, dependent: :destroy

  validates :key, presence: true, uniqueness: true
  validates :name, presence: true

  scope :ordered, -> { order(:position) }
  scope :integrated, -> { where(key: INTEGRATIONS.keys.select { |key| INTEGRATIONS[key].call }) }

  # Which platforms have a real, working integration right now — everything
  # downstream (platform breakdown cards, scan generation) is driven off
  # this, so adding a real ChatGPT/Claude/Perplexity client later means
  # dropping a lambda in here rather than hand-editing multiple views.
  INTEGRATIONS = {
    "gemini" => -> { Rails.application.credentials.dig(:gemini, :api_key).present? }
  }.freeze

  def integrated?
    INTEGRATIONS.fetch(key, -> { false }).call
  end
end
