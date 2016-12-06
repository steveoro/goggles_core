class RenameHasPayedToHasConfirmedInMeetingReservations < ActiveRecord::Migration
  def change
    rename_column( :meeting_reservations, :has_payed, :has_confirmed )
  end
end
