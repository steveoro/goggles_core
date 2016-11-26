class RenameMeetingReservationToEvent < ActiveRecord::Migration[5.0]
  def change
    rename_table :meeting_reservations, :meeting_event_reservations
  end
end
