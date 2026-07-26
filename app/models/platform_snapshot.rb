class PlatformSnapshot < ApplicationRecord
  belongs_to :scan
  belongs_to :ai_platform
  belongs_to :company, optional: true


  scope :own, -> { where(company_id: nil) }
  scope :for_company, ->(company) { where(company: company) }
end
