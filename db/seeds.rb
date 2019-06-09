# frozen_string_literal: true

# === Main Seed file for additional data ===
#
# - To be run only after the base SQL-seed load task has been executed
#   ("rake db:rebuild_from_scratch" or "rake sql_exec [db/seed/*.sql]")
#
# - Load/execute this file with:
#   > rake db:seed
#

# *** Default User / Swimmer confirmations & Friendships: ***

steve = User.where(description: 'Stefano Alloro').first
leega = User.where(description: 'Marco Ligabue').first

steve_swimmer = Swimmer.where(complete_name: 'ALLORO STEFANO').first
leega_swimmer = Swimmer.where(complete_name: 'LIGABUE MARCO').first

puts 'Setting associated swimmers...'
steve.set_associated_swimmer(steve_swimmer)
leega.set_associated_swimmer(leega_swimmer)

puts 'Setting user-swimmers confirmations...'
UserSwimmerConfirmation.confirm_for(steve, steve_swimmer, leega)
UserSwimmerConfirmation.confirm_for(leega, leega_swimmer, steve)

# [Steve, 20140723] Define default friendship for default users:
puts 'Setting default friendships...'
steve.invite(leega, true, true, true)
leega.approve(steve, true, true, true)
