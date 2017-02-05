class AddRegionTypeFieldToCity < ActiveRecord::Migration[5.0]
  def change
    add_reference :cities, :region_type, foreign_key: true
  end
end
