class CreateFinCalendars < ActiveRecord::Migration[5.0]
  def change
    create_table :fin_calendars do |t|
      t.integer :lock_version, :default => 0

      t.string :column_date
      t.string :column_name
      t.string :column_place
      t.string :fin_invitation_code
      t.string :fin_startlist_code
      t.string :fin_result_code
      t.string :goggles_meeting_code
      
      t.references :season
      t.references :user

      t.timestamps
    end
    add_index :fin_calendars, :goggles_meeting_code
  end
end
