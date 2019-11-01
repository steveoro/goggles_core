# require 'mw'


#
# == FinCalendarPhase1Cleaner
#
# Strategy to log the clean-up of no-longer existing (on-line) FIN Calendars rows.
#
# The process compares two sets of FinCalendar rows and deletes from the destination
# the rows NOT existing in the source.
#
# The process assumes that the destination instance rows are actually serialized
# on the SQL DB and logs the deletion process in the internal DB-diff text log.
#
# @author   Steve A.
# @version  6.111
#
class FinCalendarPhase1Cleaner
  include SqlConvertable

  attr_reader :destroyed_rows_codes, :error_rows_codes

  # Creates a new instance, given the current user that has "recorded" this batch
  # of operations.
  #
  def initialize( current_user )
    raise ArgumentError.new('current_user must be defined!') unless current_user.instance_of?( User )
    @destroyed_rows_codes = []
    @error_rows_codes = []
    @current_user = current_user
    create_sql_diff_header( "FinCalendarPhase1Cleaner: recorded from actions by #{ current_user }" )
  end
  #-- -------------------------------------------------------------------------
  #++


  # Returns the number of destroyed rows.
  #
  def destroyed_rows_count
    @destroyed_rows_codes.count
  end


  # Returns the number of rows that have risen errors.
  #
  def errors_count
    @error_rows_codes.count
  end
  #-- -------------------------------------------------------------------------
  #++


  # Outputs a report of the destroyed row codes plus the error ones.
  # It does nothing in case the display object does not respond to the display method.
  #
  def report( display_object = Kernel, display_method = :puts )
    return if display_method.nil? || !display_object.respond_to?( display_method )

    if destroyed_rows_count + errors_count > 0
      if destroyed_rows_count > 0
        display_object.send( display_method, "\r\n--- DESTROYED Meetings in calendar: #{ destroyed_rows_count }" )
        @destroyed_rows_codes.each do |meeting_code|
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


  # Compares two sets of FinCalendar rows and deletes from the destination
  # the rows NOT existing in the source.
  #
  # The operation alters directly the current database and logs its SQL actions
  # in the internally created DB-diff text log.
  #
  def process!( fin_calendar_source_list, fin_calendar_destination_list )
    return nil unless fin_calendar_source_list.respond_to?( :each ) &&
                      fin_calendar_destination_list.respond_to?( :each )
    # Scan destination list and keep only the rows that DO NOT have a corresponding
    # row in the source list (that is, we reject the ones that have any match):
    deletable_fin_calendar_rows = fin_calendar_destination_list.reject do |dest_row|
      fin_calendar_source_list.any? do |src_row|
        ( src_row.season_id == dest_row.season_id ) &&
        ( src_row.goggles_meeting_code == dest_row.goggles_meeting_code )
      end
    end
    # Delete each row individually, with validations:
    deletable_fin_calendar_rows.each do |dest_row|
      if dest_row.destroy
        sql_diff_text_log << to_sql_delete( dest_row, false, "\r\n" )
        @destroyed_rows_codes << "#{ dest_row.goggles_meeting_code }/#{ dest_row.id }"
      else
        sql_diff_text_log << "-- DELETE FAILURE: #{ $! }\r\n" if $!
        @error_rows_codes << "#{ dest_row.goggles_meeting_code }/#{ dest_row.id }"
      end
    end
  end
  #-- -------------------------------------------------------------------------
  #++
end