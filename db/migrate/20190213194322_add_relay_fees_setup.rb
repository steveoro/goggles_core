class AddRelayFeesSetup < ActiveRecord::Migration[5.1]
  def change
    # Badge payments setup for team manager costs calculation
    add_column( :badges, :has_to_pay_relays, :boolean, default: false, null: false )
  end
end
