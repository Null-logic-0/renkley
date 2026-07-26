class CreateRecommendations < ActiveRecord::Migration[8.1]
  def change
    create_table :recommendations do |t|
      t.references :organization, null: false, foreign_key: true
      t.string :title, null: false
      t.text :rationale, null: false
      t.integer :priority, null: false, default: 1
      t.string :category, null: false
      t.integer :effort, null: false, default: 1
      t.integer :impact_score, null: false, default: 5
      t.integer :status, null: false, default: 0
      t.integer :position, null: false, default: 0

      t.timestamps
    end
  end
end
