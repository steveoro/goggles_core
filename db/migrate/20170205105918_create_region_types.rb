# frozen_string_literal: true

class CreateRegionTypes < ActiveRecord::Migration[5.0]

  def change
    create_table :region_types do |t|
      t.integer :lock_version, default: 0

      t.string :code, limit: 3
      t.references :nation_type, foreign_key: true

      t.timestamps
    end
    add_index :region_types, :code
    add_index :region_types, [:nation_type_id, :code], name: 'index_region_types_nation_code'
  end

end
