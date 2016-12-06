class AddIsDoingThisToMeetingEventReservations < ActiveRecord::Migration
  def change
    add_column( :meeting_event_reservations, :is_doing_this, :boolean, { null: false, default: false } )
  end
end
