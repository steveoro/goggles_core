class AddNameFieldToRegionType < ActiveRecord::Migration[5.0]
  def change
    add_column :region_types, :name, :string
  end
end
