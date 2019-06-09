# frozen_string_literal: true

class AddForeignKeysToReservations < ActiveRecord::Migration[5.0]

  def change
    add_foreign_key :meeting_event_reservations, :meetings
    add_foreign_key :meeting_event_reservations, :teams
    add_foreign_key :meeting_event_reservations, :swimmers
    add_foreign_key :meeting_event_reservations, :badges
    add_foreign_key :meeting_event_reservations, :meeting_events
    add_foreign_key :meeting_event_reservations, :users
  end

end
