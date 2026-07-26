class CompetitorSnapshot < ApplicationRecord
  belongs_to :scan
  belongs_to :company
end
