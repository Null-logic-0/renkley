class CreateAiPlatforms < ActiveRecord::Migration[8.1]
  def change
    create_table :ai_platforms do |t|
      t.string :key, null: false
      t.string :name, null: false
      t.integer :position, null: false, default: 0
      t.timestamps
    end
    add_index :ai_platforms, :key, unique: true
  end
end
