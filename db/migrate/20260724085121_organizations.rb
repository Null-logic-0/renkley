class Organizations < ActiveRecord::Migration[8.1]
  def change
    create_table :organizations do |t|
      t.string :name, null: false
      t.string :slug, null: false
      t.string :website_url
      t.string :time_zone, null: false, default: "UTC"
      t.timestamps
    end
    add_index :organizations, :slug, unique: true
  end
end
