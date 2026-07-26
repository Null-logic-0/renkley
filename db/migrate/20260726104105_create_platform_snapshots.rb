class CreatePlatformSnapshots < ActiveRecord::Migration[8.1]
  def change
    create_table :platform_snapshots do |t|
      t.references :scan, null: false, foreign_key: true
      t.references :ai_platform, null: false, foreign_key: true
      t.integer :visibility_pct, null: false, default: 0
      t.integer :mentions_count, null: false, default: 0
      t.string :rank_label, null: false

      t.timestamps
    end
    add_index :platform_snapshots, [ :scan_id, :ai_platform_id ], unique: true
  end
end
