=begin

  == FinCalendarPhase3Updater

  Strategy to log the deletion of any Meeting in specified season that are deemed
  to be "deletable" since void of any results or programs and are no longer found
  linked in any fin_calendars row among the same season.

  A meeting will not be considered as "deletable" when flagged as "cancelled"
  (which it should read as "keep this, even though we won't ever acquire any
  results for it".)

  The strategy is assumed to be invoked at the end of the Phase-3 of the FIN-Calendar
  synch procedure, when all existing and defined meetings for the processed season
  should be already linked to a row.

  This class currently is used also to clean-up empty sessions left-overs from
  phase-3 ending.

  @author   Steve A.
  @version  6.120

=end
class FinCalendarPhase3Cleaner
  include SqlConvertable

  attr_reader :destroyed_rows_codes, :edited_rows_codes, :error_rows_codes

  # Creates a new instance, given the current user that has "recorded" this batch
  # of operations.
  #
  def initialize( current_user )
    raise ArgumentError.new('current_user must be defined!') unless current_user.instance_of?( User )
    @destroyed_rows_codes = []
    @edited_rows_codes = []
    @error_rows_codes = []
    @current_user = current_user
    create_sql_diff_header( "FinCalendarPhase3Cleaner: recorded from actions by #{ current_user }" )
  end
  #-- -------------------------------------------------------------------------
  #++


  # Returns true if any of the process has changed the DB somehow
  # (and the DB-diff can be saved).
  #
  def has_changes?
    (@edited_rows_codes.count > 0) || (@destroyed_rows_codes.count > 0)
  end
  #-- -------------------------------------------------------------------------
  #++


  # Returns the number of edited rows.
  #
  def edited_rows_count
    @edited_rows_codes.count
  end


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

    if destroyed_rows_count + edited_rows_count + errors_count > 0
      # Destroyed rows can either be Meetings or MeetingSessions.
      # For meetings, the text code will be a combo of its code & its ID.
      # For sessions, the text code will be a combo of its meeting.id & its ID.
      if destroyed_rows_count > 0
        display_object.send( display_method, "\r\n--- DESTROYED rows in specified season: #{ destroyed_rows_count }" )
        @destroyed_rows_codes.each do |code|
          display_object.send( display_method, "- #{ code }" )
        end
      end
      # Edited rows can only refer to cancelled meetings:
      if edited_rows_count > 0
        display_object.send( display_method, "\r\n--- CANCELLED Meetings in calendar: #{ edited_rows_count }" )
        @edited_rows_codes.each do |code|
          display_object.send( display_method, "- #{ code }" )
        end
      end
      # Error codes may refer to both Meetings or MeetingSessions deletion:
      if errors_count > 0
        display_object.send( display_method, "\r\n--- Tot. ERRORS during calendar processing: #{ errors_count }" )
        @error_rows_codes.each do |code|
          display_object.send( display_method, "- #{ code }" )
        end
      end
    end
  end
  #-- -------------------------------------------------------------------------
  #++


  # Collects all the "deletable" Meetings belonging to the specified season.
  #
  # A meeting will be deemed as "deletable" if:
  #
  # - Have no results (both individual and relays)
  # - Have its are_results_acquired? flag set to false
  # - Have its is_cancelled? flag set to false
  # - Have no associated fin_calendars row by code.
  #
  def collect_deletable_meetings( season_id )
    # Build up a list of meeting codes for the specified season:
    codes = FinCalendar.where( season_id: season_id ).map{|row| row.goggles_meeting_code }
    # Filter-out the meetings: we need the ones that do not have the results flag
    # triggered and are not enlisted in the calendar:
    deletable_meetings = Meeting.where(
      "(season_id = ?) AND (code NOT IN (?)) AND (are_results_acquired = 0) AND (is_cancelled = 0)",
      season_id, codes
    ).to_a

    # Discard from the filtered meetings any which have some associated results
    # anyhow:
    deletable_meetings.reject! do |meeting|
      (meeting.meeting_individual_results.count > 0) ||
      (meeting.meeting_relay_results.count > 0)
    end

    # Return the list of deletable meetings:
    deletable_meetings
  end
  #-- -------------------------------------------------------------------------
  #++


  # Deletes all the specified Meeting rows and all its related entities (assuming
  # the foreign contraints are in place) while logging the operation, creating a
  # repeatable DB-diff text log of the action.
  #
  # Whenever +use_disable+ is set to true it will just update all specified
  # Meeting rows, setting their +is_cancelled+ flag to +true+ istead of destroying
  # the row instance.
  #
  def process!( deletable_meeting_list, use_disable = false )
    # Bail out in case of invalid parameter:
    return nil unless deletable_meeting_list.respond_to?( :each )

    # Delete each row individually, with validations:
    deletable_meeting_list.each do |meeting|
      if use_disable                                # -- Disable the meeting --
        meeting.is_cancelled = true
        sql_diff_text_log << "\r\n-- Disabling useless Meeting #{ meeting.id }, code '#{ meeting.code }'\r\n"
        if meeting.save
          sql_attributes = { is_cancelled: true  }
          sql_diff_text_log << to_sql_update( meeting, false, sql_attributes, "\r\n" )
          @edited_rows_codes << "#{meeting.code}/#{meeting.id}"
        else
          sql_diff_text_log << "-- UPDATE VALIDATION FAILURE in FinCalendarPhase3Cleaner: #{ ValidationErrorTools.recursive_error_for( meeting ) }\r\n" if meeting.invalid?
          sql_diff_text_log << "-- UPDATE FAILURE: #{ $! }\r\n" if $!
          @error_rows_codes << "#{meeting.code}/#{meeting.id}"
        end
                                                    # -- Destroy the meeting --
      else
        sql_diff_text_log << "\r\n-- Destroying useless Meeting #{ meeting.id }, code '#{ meeting.code }'\r\n"
        result_log = destroy_with_sql_capture( meeting )
        unless result_log.nil?
          sql_diff_text_log << result_log
          @destroyed_rows_codes << "#{meeting.code}/#{meeting.id}"
        else
          sql_diff_text_log << "-- DELETE FAILURE: #{ $! }\r\n" if $!
          @error_rows_codes << "#{meeting.code}/#{meeting.id}"
        end
      end
    end
  end
  #-- -------------------------------------------------------------------------
  #++


  # Scans the whole season specified and deletes any empty session found (while
  # logging the process).
  #
  # The scan loops on all season's Meetings having "empty" sessions; that is,
  # sessions that do not have (anymore) any associated events. These are deemed
  # as "deletable".
  #
  # An "empty" session could be the result of the event builder updates (due to
  # the "relocation" of the events of the session), or the result of all the
  # adjustments made by the fin_calendar synch task on Meetings results acquired
  # with "automatic" event creation turned on.
  #
  # (Since the results data-import procedure does not parse the meeting manifest
  #  as the fin_calendar task does, it's not capable of creating correct events
  # or sessions by itself. Typically, the data-import should be run only _after_
  # the fin_calendar synch task has "fixed" the meeting calendar, building all
  # the meetings with their correct sessions and events.)
  #
  def remove_empty_sessions!( season_id )
    sql_diff_text_log << "\r\n-- Processing season #{ season_id } for empty sessions...\r\n"
    # Build up a list of meeting sessions that are completely empty and deletable:
    deletable_season_sessions = Meeting.includes(:meeting_sessions).joins(:meeting_sessions)
        .where( season_id: season_id )
        .map{ |m| m.meeting_sessions }
        .flatten
        .reject{ |ms| ms.meeting_events.count > 0 }

    if deletable_season_sessions.count > 0
      sql_diff_text_log << "-- Found #{ deletable_season_sessions.count } deletable (empty) sessions in season #{ season_id }. Cleaning-up...\r\n\r\n"
    end

    # Delete each row individually, with validations:
    deletable_season_sessions.each do |dest_row|
      if dest_row.destroy
        sql_diff_text_log << "-- MeetingSession empty in meeting #{ dest_row.meeting_id }\r\n"
        sql_diff_text_log << to_sql_delete( dest_row, false, "\r\n" )
        @destroyed_rows_codes << "#{ dest_row.meeting_id }/#{ dest_row.id }"
      else
        sql_diff_text_log << "-- DELETE FAILURE: #{ $! }\r\n" if $!
        @error_rows_codes << "#{ dest_row.meeting_id }/#{ dest_row.id }"
      end
    end
  end
  #-- -------------------------------------------------------------------------
  #++
end
