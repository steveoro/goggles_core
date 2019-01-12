class AddMoreSetupToGoggleCup < ActiveRecord::Migration[5.1]
  def change
    # Add columns to increase calculation variety
    add_column( :goggle_cups, :is_team_limited, :boolean, default: true )
    add_column( :goggle_cups, :career_step, :integer, default: 100 )
    add_column( :goggle_cups, :career_bonus, :decimal, precision: 10, scale: 2, default: 0.0 )
  end
end
