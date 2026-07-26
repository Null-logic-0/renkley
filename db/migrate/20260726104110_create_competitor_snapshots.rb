class CreateCompetitorSnapshots < ActiveRecord::Migration[8.1]
  def change
    create_table :competitor_snapshots do |t|
      t.references :scan, null: false, foreign_key: true
      t.references :company, null: false, foreign_key: true
      t.integer :score, null: false, default: 0
      t.integer :chatgpt_mentions, null: false, default: 0
      t.integer :claude_mentions, null: false, default: 0
      t.integer :google_ai_mentions, null: false, default: 0
      t.integer :citations_count, null: false, default: 0

      t.timestamps
    end
    add_index :competitor_snapshots, [ :scan_id, :company_id ], unique: true
  end
end
