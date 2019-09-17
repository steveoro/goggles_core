# frozen_string_literal: true

class RenameColumnNameToCalendarNameInFinCalendars < ActiveRecord::Migration

  def change
    change_table :fin_calendars, bulk: true do |t|
      t.rename_column(:column_name, :calendar_name)
      t.rename_column(:column_date, :calendar_date)
      t.rename_column(:column_place, :calendar_place)
    end
  end

end
