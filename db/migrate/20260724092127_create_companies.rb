class CreateCompanies < ActiveRecord::Migration[8.1]
  def change
    create_table :companies do |t|
      t.references :organization, null: false, foreign_key: true
      t.string :name, null: false
      t.string :domain, null: false
      t.integer :kind, null: false, default: 0
      t.integer :source, null: false, default: 0
      t.integer :position, null: false, default: 0
      t.timestamps
    end
    add_index :companies, :organization_id, :domain, unique: true
  end
end
