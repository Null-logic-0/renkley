class CreateOnboardingTasks < ActiveRecord::Migration[8.1]
  def change
    create_table :onboarding_tasks do |t|
      t.references :organization, null: false, foreign_key: true
      t.string :key, null: false
      t.string :label, null: false
      t.integer :status, null: false, default: 0
      t.integer :position, null: false, default: 0
      t.datetime :started_at
      t.datetime :finished_at
      t.timestamps
    end
    add_index :onboarding_tasks, [:organization_id, :key], unique: true
  end
end
