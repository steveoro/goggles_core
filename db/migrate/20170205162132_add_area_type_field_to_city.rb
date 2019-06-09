# frozen_string_literal: true

class AddAreaTypeFieldToCity < ActiveRecord::Migration[5.0]

  def change
    execute <<-SQL
      ALTER TABLE cities
        DROP FOREIGN KEY fk_rails_06d0b7d4d2
    SQL

    change_table :cities do |t|
      t.remove_index(name: 'index_cities_on_region_type_id')
      t.remove_references(:region_type)
      t.references :area_type, foreign_key: true
    end
  end

end
