class AddSearchVolumeToPrompts < ActiveRecord::Migration[8.1]
  def change
    add_column :prompts, :search_volume, :integer, null: false, default: 1
  end
end
