class CreateCitations < ActiveRecord::Migration[8.1]
  def change
    create_table :citations do |t|
      t.references :organization, null: false, foreign_key: true
      t.string :domain, null: false
      t.integer :authority_score, null: false, default: 0
      t.integer :mentions_count, null: false, default: 0
      t.integer :your_share_pct, null: false, default: 0
      t.integer :competitor_share_pct, null: false, default: 0
      t.integer :trend, null: false, default: 0
      t.references :last_scan, foreign_key: { to_table: :scans }

      t.timestamps
    end
    add_index :citations, [ :organization_id, :domain ], unique: true
  end
end
