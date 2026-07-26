class CreatePromptResults < ActiveRecord::Migration[8.1]
  def change
    create_table :prompt_results do |t|
      t.references :scan, null: false, foreign_key: true
      t.references :prompt, null: false, foreign_key: true
      t.references :ai_platform, null: false, foreign_key: true
      t.integer :your_position
      t.references :top_competitor_company, foreign_key: { to_table: :companies }
      t.references :winner_company, null: false, foreign_key: { to_table: :companies }

      t.timestamps
    end
    add_index :prompt_results, [ :scan_id, :prompt_id ], unique: true
  end
end
