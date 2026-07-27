class CreateBrandAliases < ActiveRecord::Migration[8.1]
  def change
    create_table :brand_aliases do |t|
      t.references :organization, null: false, foreign_key: true
      t.string :name, null: false

      t.timestamps
    end
    add_index :brand_aliases, [ :organization_id, :name ], unique: true
  end
end
