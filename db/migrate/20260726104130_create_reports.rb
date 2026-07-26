class CreateReports < ActiveRecord::Migration[8.1]
  def change
    create_table :reports do |t|
      t.references :organization, null: false, foreign_key: true
      t.string :name, null: false
      t.text :description, null: false
      t.string :frequency, null: false
      t.string :report_kind, null: false
      t.integer :tag, null: false, default: 0

      t.timestamps
    end
  end
end
