# frozen_string_literal: true

class CreateMeetingRelayReservations < ActiveRecord::Migration[5.0]

  def change
    create_table :meeting_relay_reservations do |t|
      t.references :meeting, foreign_key: true
      t.references :user, foreign_key: true
      t.references :team, foreign_key: true
      t.references :swimmer, foreign_key: true
      t.references :badge, foreign_key: true
      t.references :meeting_event, foreign_key: true
      t.string :notes, limit: 50
      t.boolean :is_doing_this

      t.timestamps
    end
  end

end
