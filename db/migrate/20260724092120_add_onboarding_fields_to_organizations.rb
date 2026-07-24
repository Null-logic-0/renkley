class AddOnboardingFieldsToOrganizations < ActiveRecord::Migration[8.1]
  def change
    add_column :organizations, :onboarding_step, :integer, null: false, default: 1
    add_column :organizations, :onboarding_status, :integer, null: false, default: 0
  end
end
