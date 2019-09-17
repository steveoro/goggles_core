# frozen_string_literal: true

class AddSetupToGoggleCup < ActiveRecord::Migration[5.1]

  def change
    change_table :goggle_cups, bulk: true do |t|
      # Add columns that were hard-coded
      t.column(:age_for_negative_modifier, :integer, default: 20)
      t.column(:negative_modifier, :decimal, precision: 10, scale: 2, default: -10.0)
      t.column(:age_for_positive_modifier, :integer, default: 60)
      t.column(:positive_modifier, :decimal, precision: 10, scale: 2, default: 5.0)
      t.column(:has_to_create_standards, :boolean, default: true)
      t.column(:has_to_update_standards, :boolean, default: false)

      # Add columns to perform pre & post SQL in Goggle Cup calculation
      t.column(:pre_calculation_sql, :text)
      t.column(:post_calculation_sql, :text)
    end
  end

end
