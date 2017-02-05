class CreateRegionTypes < ActiveRecord::Migration[5.0]
  def change
    create_table :region_types do |t|
      t.integer :lock_version, :default => 0

      t.string :code, limit: 3

      t.timestamps
    end
    add_index :region_types, :code
  end
end
