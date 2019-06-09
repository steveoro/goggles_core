# frozen_string_literal: true

class CreateNationTypes < ActiveRecord::Migration[5.0]

  def change
    create_table :nation_types do |t|
      t.integer :lock_version, default: 0

      t.string :code, limit: 3
      t.string :numeric_code, limit: 3
      t.string :alpha2_code, limit: 2

      t.timestamps
    end
    add_index :nation_types, :code, unique: true
  end

end
