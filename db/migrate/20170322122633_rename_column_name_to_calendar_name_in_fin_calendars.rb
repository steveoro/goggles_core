class RenameColumnNameToCalendarNameInFinCalendars < ActiveRecord::Migration
  def change
    rename_column( :fin_calendars, :column_name, :calendar_name )
    rename_column( :fin_calendars, :column_date, :calendar_date )
    rename_column( :fin_calendars, :column_place, :calendar_place )
  end
end
