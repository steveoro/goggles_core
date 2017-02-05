class AddNationTypeIdFieldToRegionType < ActiveRecord::Migration[5.0]
  def change
    add_reference :region_types, :nation_type, foreign_key: true
  end
end
