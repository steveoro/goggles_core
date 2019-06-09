# frozen_string_literal: true

class CreateMeetingReservations < ActiveRecord::Migration[5.0]

  def change
    create_table :meeting_reservations do |t|
      t.references :meeting, foreign_key: true
      t.references :user, foreign_key: true
      t.references :team, foreign_key: true
      t.references :swimmer, foreign_key: true
      t.references :badge, foreign_key: true
      t.text :notes
      t.boolean :is_not_coming
      t.boolean :has_payed

      t.timestamps
    end
  end

end
