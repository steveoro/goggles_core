# frozen_string_literal: true

class AddFeesToTeamManagement < ActiveRecord::Migration[5.1]

  def change
    # Meeting fees for team manager costs calculation
    add_column(:meetings, :meeting_fee, :decimal, precision: 10, scale: 2)
    add_column(:meetings, :event_fee, :decimal, precision: 10, scale: 2)
    add_column(:meetings, :relay_fee, :decimal, precision: 10, scale: 2)

    # Season fees for team manager costs calculation
    add_column(:seasons, :badge_fee, :decimal, precision: 10, scale: 2)

    # Badge payments setup for team manager costs calculation
    add_column(:badges, :has_to_pay_fees, :boolean, default: false, null: false)
    add_column(:badges, :has_to_pay_badge, :boolean, default: false, null: false)

    # To store payments by badge so we can check with respective meetings and season fees
    create_table :badge_payments do |t|
      t.integer :lock_version, default: 0

      t.decimal :amount, precision: 10, scale: 2
      t.date :payment_date
      t.text :notes
      t.boolean :is_manual

      t.references :badge
      t.references :user

      t.timestamps
    end
  end

end
