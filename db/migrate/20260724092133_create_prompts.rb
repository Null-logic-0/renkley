class CreatePrompts < ActiveRecord::Migration[8.1]
  def change
    create_table :prompts do |t|
      t.references :organization, null: false, foreign_key: true
      t.text :body, null: false
      t.integer :source, null: false, default: 0
      t.integer :position, null: false, default: 0
      t.timestamps
    end
  end
end
