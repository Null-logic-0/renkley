class AddSettingsFieldsToOrganizations < ActiveRecord::Migration[8.1]
  def change
    add_column :organizations, :category, :string
    add_column :organizations, :default_ai_platform, :string
    add_column :organizations, :scan_frequency, :integer, default: 1, null: false
  end
end
