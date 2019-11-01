# require 'mw'


#
# == FinCalendarPhase2Updater
#
# Strategy to log the updates og FinCalendar rows during the "phase-3" of the
# crawler:fin_calendar group of tasks.
#
# @author   Steve A.
# @version  6.111
#
class FinCalendarPhase2Updater
  include SqlConvertable

  attr_reader :edited_rows_codes, :error_rows_codes

  # Creates a new instance, given the current user that has "recorded" this batch
  # of operations.
  #
  def initialize( current_user )
    raise ArgumentError.new('current_user must be defined!') unless current_user.instance_of?( User )
    @edited_rows_codes = []
    @error_rows_codes = []
    @current_user = current_user
    create_sql_diff_header( "FinCalendarPhase2Updater: recorded from actions by #{ current_user }" )
  end
  #-- -------------------------------------------------------------------------
  #++


  # Returns the number of edited rows.
  #
  def edited_rows_count
    @edited_rows_codes.count
  end


  # Returns the number of rows that have risen errors.
  #
  def errors_count
    @error_rows_codes.count
  end
  #-- -------------------------------------------------------------------------
  #++


  # Compares for difference two FinCalendar rows.
  # Returns true if any of the columns containing the calendar text data
  # differs in content. NULL and empty values are considered the same.
  # (An update must be performed only when actual contents are different.)
  #
  def self.is_different?( fin_calendar_row_1, fin_calendar_row_2 )
    (fin_calendar_row_1.manifest.to_s         != fin_calendar_row_2.manifest.to_s)      ||
    (fin_calendar_row_1.meeting_id.to_s       != fin_calendar_row_2.meeting_id.to_s)    ||
    (fin_calendar_row_1.organization_import_text.to_s != fin_calendar_row_2.organization_import_text.to_s) ||
    (fin_calendar_row_1.name_import_text.to_s         != fin_calendar_row_2.name_import_text.to_s)         ||
    (fin_calendar_row_1.place_import_text.to_s        != fin_calendar_row_2.place_import_text.to_s)        ||
    (fin_calendar_row_1.dates_import_text.to_s        != fin_calendar_row_2.dates_import_text.to_s)        ||
    (fin_calendar_row_1.program_import_text.to_s      != fin_calendar_row_2.program_import_text.to_s)
  end
  #-- -------------------------------------------------------------------------
  #++


  # Outputs a report of the modified row codes plus the error ones.
  # It does nothing in case the display object does not respond to the display method.
  #
  def report( display_object = Kernel, display_method = :puts )
    return if display_method.nil? || !display_object.respond_to?( display_method )

    if edited_rows_count + errors_count > 0
      if edited_rows_count > 0
        display_object.send( display_method, "\r\n--- UPDATED Meetings in calendar: #{ edited_rows_count }" )
        @edited_rows_codes.each do |meeting_code|
          display_object.send( display_method, "- #{ meeting_code }" )
        end
      end
      if errors_count > 0
        display_object.send( display_method, "\r\n--- Tot. ERRORS during calendar processing: #{ errors_count }" )
        @error_rows_codes.each do |meeting_code|
          display_object.send( display_method, "- #{ meeting_code }" )
        end
      end
    end
  end
  #-- -------------------------------------------------------------------------
  #++


  # This simply saves the specified row while logging the changes for all its columns
  # used during the phase-2 of the FinCalendar synchronization procedure.
  #
  def process_row!( fin_calendar_row )
    return nil unless fin_calendar_row.instance_of?( FinCalendar )
    existing_calendar_row = FinCalendar.find( fin_calendar_row.id )
    if FinCalendarPhase2Updater.is_different?( fin_calendar_row, existing_calendar_row )
      if fin_calendar_row.save
        # Main data extracted during phase-2 synch:
        # relevant_data_hash[ :meeting_dates ]    => fin_calendars.dates_import_text
        # relevant_data_hash[ :entry_date_limit ] => fin_calendars.name_import_text
        # relevant_data_hash[ :organization ]     => fin_calendars.organization_import_text
        # relevant_data_hash[ :program ]          => fin_calendars.program_import_text
        sql_attributes = fin_calendar_row.attributes.select do |key|
          [
            'manifest', 'name_import_text', 'organization_import_text',
            'place_import_text', 'dates_import_text',
            'program_import_text', 'meeting_id'
          ].include?( key.to_s )
        end
        sql_diff_text_log << to_sql_update( fin_calendar_row, false, sql_attributes, "\r\n" )
        @edited_rows_codes << "#{ fin_calendar_row.goggles_meeting_code }/#{ fin_calendar_row.id }"
      else
        sql_diff_text_log << "-- UPDATE VALIDATION FAILURE during FinCalendar Phase-2: #{ ValidationErrorTools.recursive_error_for( fin_calendar_row ) }\r\n" if fin_calendar_row.invalid?
        sql_diff_text_log << "-- UPDATE FAILURE: #{ $! }\r\n" if $!
        @error_rows_codes << "#{ fin_calendar_row.goggles_meeting_code }/#{ fin_calendar_row.id }"
      end
    end
  end
  #-- -------------------------------------------------------------------------
  #++
end