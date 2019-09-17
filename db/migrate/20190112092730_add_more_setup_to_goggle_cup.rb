# frozen_string_literal: true

class AddMoreSetupToGoggleCup < ActiveRecord::Migration[5.1]

  def change
    # Add columns to increase calculation variety
    change_table :goggle_cups, bulk: true do |t|
      t.column(:is_team_limited, :boolean, default: true)
      t.column(:career_step, :integer, default: 100)
      t.column(:career_bonus, :decimal, precision: 10, scale: 2, default: 0.0)
    end
  end

end
