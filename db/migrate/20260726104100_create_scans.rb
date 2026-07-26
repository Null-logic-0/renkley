class CreateScans < ActiveRecord::Migration[8.1]
  def change
    create_table :scans do |t|
      t.references :organization, null: false, foreign_key: true
      t.integer :status, null: false, default: 0
      t.datetime :started_at
      t.datetime :finished_at
      t.integer :overall_score
      t.integer :ranking_position
      t.integer :mentions_count
      t.decimal :citation_share_pct, precision: 5, scale: 1

      t.timestamps
    end
  end
end
