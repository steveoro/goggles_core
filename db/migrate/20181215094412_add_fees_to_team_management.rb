# frozen_string_literal: true

class AddFeesToTeamManagement < ActiveRecord::Migration[5.1]

  def change
    # Meeting fees for team manager costs calculation
    change_table :meetings, bulk: true do |t|
      t.column(:meeting_fee, :decimal, precision: 10, scale: 2)
      t.column(:event_fee, :decimal, precision: 10, scale: 2)
      t.column(:relay_fee, :decimal, precision: 10, scale: 2)
    end

    # Season fees for team manager costs calculation
    change_table :seasons, bulk: true do |t|
      t.column(:badge_fee, :decimal, precision: 10, scale: 2)
    end

    # Badge payments setup for team manager costs calculation
    change_table :badges, bulk: true do |t|
      t.column(:has_to_pay_fees, :boolean, default: false, null: false)
      t.column(:has_to_pay_badge, :boolean, default: false, null: false)
    end

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
