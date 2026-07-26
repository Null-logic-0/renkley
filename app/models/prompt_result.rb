class PromptResult < ApplicationRecord
  belongs_to :scan
  belongs_to :prompt
  belongs_to :ai_platform
  belongs_to :top_competitor_company, class_name: "Company", optional: true
  belongs_to :winner_company, class_name: "Company"

  def you_won? = winner_company.owned?
end
