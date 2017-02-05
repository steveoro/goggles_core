class CreateAreaTypes < ActiveRecord::Migration[5.0]
  def change
    create_table :area_types do |t|
      t.integer :lock_version, :default => 0

      t.string :code, limit: 10
      t.string :name
      t.references :region_type, foreign_key: true

      t.timestamps
    end
    add_index :area_types, :code
    add_index :area_types, [:region_type_id, :code], name: 'index_area_types_region_code'
  end
end
