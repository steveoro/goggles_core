# frozen_string_literal: true

class AddSetupToGoggleCup < ActiveRecord::Migration[5.1]

  def change
    # Add columns that was hard-coded
    add_column(:goggle_cups, :age_for_negative_modifier, :integer, default: 20)
    add_column(:goggle_cups, :negative_modifier, :decimal, precision: 10, scale: 2, default: -10.0)
    add_column(:goggle_cups, :age_for_positive_modifier, :integer, default: 60)
    add_column(:goggle_cups, :positive_modifier, :decimal, precision: 10, scale: 2, default: 5.0)
    add_column(:goggle_cups, :has_to_create_standards, :boolean, default: true)
    add_column(:goggle_cups, :has_to_update_standards, :boolean, default: false)

    # Add columns to perform pre & post SQL in Goggle Cup calculation
    add_column(:goggle_cups, :pre_calculation_sql, :text)
    add_column(:goggle_cups, :post_calculation_sql, :text)
  end

end
