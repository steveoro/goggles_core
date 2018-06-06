class AddDoNotUpdateFlagToSwimmingPool < ActiveRecord::Migration[5.1]
  def change
    # Crawler-only flag:
    add_column( :swimming_pools, :do_not_update, :boolean, default: false, null: false, index: true )
  end
end
