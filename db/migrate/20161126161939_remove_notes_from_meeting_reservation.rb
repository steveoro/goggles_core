class RemoveNotesFromMeetingReservation < ActiveRecord::Migration[5.0]
  def change
    remove_column :meeting_reservations, :notes
  end
end
