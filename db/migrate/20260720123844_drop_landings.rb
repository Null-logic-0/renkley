class DropLandings < ActiveRecord::Migration[8.1]
  def change
    drop_table :landings do |t|
      t.timestamps
    end
  end
end
