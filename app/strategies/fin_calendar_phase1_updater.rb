# require 'mw'


#
# == FinCalendarPhase1Updater
#
# Strategy to log either the update or the creation of FinCalendar rows
# during the "phase-1" of the crawler:fin_calendar group of tasks.
#
# @author   Steve A.
# @version  6.106
#
class FinCalendarPhase1Updater
  include SqlConvertable

  attr_reader :edited_rows_codes, :created_rows_codes,
              :error_rows_codes

  # Creates a new instance, given the current user that has "recorded" this batch
  # of operations.
  #
  def initialize( current_user )
    raise ArgumentError.new('current_user must be defined!') unless current_user.instance_of?( User )
    @edited_rows_codes = []
    @created_rows_codes = []
    @error_rows_codes = []
    @current_user = current_user
    create_sql_diff_header( "FinCalendarPhase1Updater: recorded from actions by #{ current_user }" )
  end
  #-- -------------------------------------------------------------------------
  #++


  # Returns the number of edited rows.
  #
  def edited_rows_count
    @edited_rows_codes.count
  end


  # Returns the number of created rows.
  #
  def created_rows_count
    @created_rows_codes.count
  end


  # Returns the number of rows that have risen errors.
  #
  def errors_count
    @error_rows_codes.count
  end


  # Returns the total number of processed rows (excluding the skipped ones).
  #
  def processed_rows
    edited_rows_count + created_rows_count
  end
  #-- -------------------------------------------------------------------------
  #++


  # Compares for difference two FinCalendar rows.
  # Returns true if any of the columns containing calendar data or links
  # differs in content. NULL and empty values are considered the same.
  # (An update must be performed only when actual contents are different.)
  #
  def self.is_different?( fin_calendar_row_1, fin_calendar_row_2 )
    (fin_calendar_row_1.calendar_year.to_s   != fin_calendar_row_2.calendar_year.to_s)  ||
    (fin_calendar_row_1.calendar_month.to_s  != fin_calendar_row_2.calendar_month.to_s) ||
    (fin_calendar_row_1.calendar_date.to_s   != fin_calendar_row_2.calendar_date.to_s)  ||
    (fin_calendar_row_1.calendar_place.to_s  != fin_calendar_row_2.calendar_place.to_s) ||
    (fin_calendar_row_1.results_link.to_s    != fin_calendar_row_2.results_link.to_s)   ||
    (fin_calendar_row_1.startlist_link.to_s  != fin_calendar_row_2.startlist_link.to_s) ||
    (fin_calendar_row_1.manifest_link.to_s   != fin_calendar_row_2.manifest_link.to_s)  ||
    (fin_calendar_row_1.calendar_name.to_s   != fin_calendar_row_2.calendar_name.to_s)
  end
  #-- -------------------------------------------------------------------------
  #++


  # Outputs a report of the modified row codes plus the error ones.
  # It does nothing in case the display object does not respond to the display method.
  #
  def report( display_object = Kernel, display_method = :puts )
    return if display_method.nil? || !display_object.respond_to?( display_method )

    if processed_rows + errors_count > 0
      if edited_rows_count > 0
        display_object.send( display_method, "\r\n--- UPDATED Meetings in calendar: #{ edited_rows_count }" )
        @edited_rows_codes.each do |meeting_code|
          display_object.send( display_method, "- #{ meeting_code }" )
        end
      end
      if created_rows_count > 0
        display_object.send( display_method, "\r\n--- CREATED Meetings in calendar: #{ created_rows_count }" )
        @created_rows_codes.each do |meeting_code|
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


  # This performs a single row processing, checking for pre-existing calendar rows
  # and resulting in either an update or a new row creation.
  #
  # The operation alters directly the current database and logs its SQL actions
  # in the internally created DB-diff text log.
  #
  def process_row!( fin_calendar_row )
    return nil unless fin_calendar_row.instance_of?( FinCalendar )
    # Set the default user_id:
    fin_calendar_row.user_id = @current_user.id

    # Compare w/ table values. First, get the existing calendar row, if it exists:
    existing_calendar_row = FinCalendar.where(
      season_id: fin_calendar_row.season_id,
      goggles_meeting_code: fin_calendar_row.goggles_meeting_code
    ).first

    if existing_calendar_row                      # Found? *** EDIT ***
      if FinCalendarPhase1Updater.is_different?( fin_calendar_row, existing_calendar_row )
        # Overwrite fields value w/ updated version:
        # (Remote fin_calendar always wins => update existing w/ new values)
        existing_calendar_row.calendar_year   = fin_calendar_row.calendar_year
        existing_calendar_row.calendar_month  = fin_calendar_row.calendar_month
        existing_calendar_row.calendar_date   = fin_calendar_row.calendar_date
        existing_calendar_row.calendar_place  = fin_calendar_row.calendar_place
        existing_calendar_row.results_link    = fin_calendar_row.results_link
        existing_calendar_row.startlist_link  = fin_calendar_row.startlist_link
        existing_calendar_row.manifest_link   = fin_calendar_row.manifest_link
        existing_calendar_row.calendar_name   = fin_calendar_row.calendar_name

        if existing_calendar_row.save
          sql_attributes = existing_calendar_row.attributes.select do |key|
            [
              'calendar_year', 'calendar_month', 'calendar_date', 'calendar_place',
              'results_link', 'startlist_link', 'manifest_link', 'calendar_name',
              'user_id'
            ].include?( key.to_s )
          end
          sql_diff_text_log << to_sql_update( existing_calendar_row, false, sql_attributes, "\r\n" )
          @edited_rows_codes << "#{ existing_calendar_row.goggles_meeting_code }/#{ existing_calendar_row.id }"
        else
          sql_diff_text_log << "-- UPDATE VALIDATION FAILURE during FinCalendar Phase-1: #{ ValidationErrorTools.recursive_error_for( existing_calendar_row ) }\r\n" if existing_calendar_row.invalid?
          sql_diff_text_log << "-- UPDATE FAILURE: #{ $! }\r\n" if $!
          @error_rows_codes << "#{ existing_calendar_row.goggles_meeting_code }/#{ existing_calendar_row.id }"
        end
      end
    else                                            # *** CREATE NEW ***
      if fin_calendar_row.save
        sql_diff_text_log << to_sql_insert( fin_calendar_row, false, "\r\n" )
        @created_rows_codes << "#{ fin_calendar_row.goggles_meeting_code }/#{ fin_calendar_row.id }"
      else
        sql_diff_text_log << "-- INSERT VALIDATION FAILURE during FinCalendar Phase-1: #{ ValidationErrorTools.recursive_error_for( fin_calendar_row ) }\r\n" if fin_calendar_row.invalid?
        sql_diff_text_log << "-- INSERT FAILURE: #{ $! }\r\n" if $!
        @error_rows_codes << "#{ fin_calendar_row.goggles_meeting_code }/#{ fin_calendar_row.id }"
      end
    end
  end
  #-- -------------------------------------------------------------------------
  #++
end