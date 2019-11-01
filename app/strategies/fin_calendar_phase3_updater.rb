
=begin

  == FinCalendarPhase3Updater

  Strategy to log the updates og FinCalendar rows during the "phase-3" of the
  crawler:fin_calendar group of tasks.

  @author   Steve A.
  @version  6.129

=end
class FinCalendarPhase3Updater
  include SqlConvertable

  attr_reader :edited_rows_codes, :error_rows_codes, :action_log


=begin
  Creates a new instance, given the current user that has "recorded" this batch
  of operations.

  === Params:

  - current_user : the current User running and logging this process.

  - 'honor_single_update':  when 'true' (default) every Pool or City gets updated
                      at most a single time every run or every 30 minutes, depending
                      on which occurs first.

                      This is useful to ignore apparent subsequent changes found
                      when looping amongst all the rows of a calendar. Since
                      all values take origin from hand-written data, for instance,
                      a pool address may be found written in several different ways
                      even though all referring to the same address.

                      With the default on, an update to a Pool or City row found
                      having different values will be allowed only if the row itself
                      will be found +updated_on+ more than 30 minutes ago. (This is
                      the default timeout for the "single-update" feature.)

  - geocoder_api_key : the Google Maps API Key for the internal Geocoder instance.

=end
  def initialize( current_user, honor_single_update = true, geocoder_api_key = nil )
    raise ArgumentError.new('current_user must be defined!') unless current_user.instance_of?( User )
    @edited_rows_codes = []
    @error_rows_codes = []
    @current_user = current_user
    @action_log = []
    @has_changed_the_db = false
    @honor_single_update = honor_single_update
    @geocoder_api_key = geocoder_api_key
  end
  #-- -------------------------------------------------------------------------
  #++


  # Returns true if any of the internal builder instances has changed the DB
  # (and the DB-diff can be saved).
  #
  def has_changes?
    @has_changed_the_db
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


  # Given the source fin_calendar_row and the session DAOs resulting from the parsing
  # of the meeting program, creates or updates the main entities of the meeting
  # represented by the fin_calendar row using internal dedicated builder instances.
  #
  # The fin_calendar gets updated at the end with a link to the correct meeting
  # row, if still unbound.
  #
  # A calendar row will be considered as "incomplete" and it will NOT be processed
  # when missing *all* of the following:
  #
  # - a program text (extracted from from the manifest);
  # - a goggles meeting.code;
  # - a calendar name;
  #
  # The whole process is logged and a single DB-diff text log is internally stored
  # during each call (at the start of the call both the process log and the DB-diff
  # log are cleared out).
  #
  # Whenever a Meeting is found with +are_results_acquired?+ true, usually the
  # rest of the calendar row processing gets skipped.
  #
  # To force its processing and its consequent possible update (of sessions,
  # events, pool and city), just specify +false+ for the skip_acquired_meetings
  # parameter.
  #
  def process_row!( fin_calendar_row, session_daos, force_geocoding_search = false,
                    skip_acquired_meetings = true )
    return nil unless fin_calendar_row.instance_of?( FinCalendar )

    # Prepare one DB-diff for each source row and append to a single action log
    # all the actions taken, by collecting each #sql_diff_text_log & report log
    # from each builder after it has finished its job:
    @action_log = [
      "\r\n" + "*" * 100,
      "--  Processing FIN Calendar row ID: #{ fin_calendar_row.id }, '#{ fin_calendar_row.goggles_meeting_code }'  --".center(100),
      "Session DAOs: #{ session_daos.count }, force geocoding: #{ force_geocoding_search ? 'ON': 'OFF' }".center(100),
      "*" * 100 + "\r\n\r\n",
      "\t- force_geocoding_search: #{ force_geocoding_search }",
      "\t- skip_acquired_meetings: #{ skip_acquired_meetings }\r\n",
      "\t- Session DAOs:",
      session_daos.join("\r\n")
    ]
    reset_sql_diff_text_log
    @has_changed_the_db = false

    # If we don't have the program text to parse or we can't figure out which Meeting
    # the calendar row refers to, we skip it:
    unless fin_calendar_row.program_import_text.present? &&
           fin_calendar_row.goggles_meeting_code.present? &&
           fin_calendar_row.calendar_name.present?
      @action_log << "\r\n=> Incomplete calendar row, skipping processing: '#{ fin_calendar_row.get_verbose_name }'!\r\n"
      @error_rows_codes << "#{ fin_calendar_row.goggles_meeting_code }/#{ fin_calendar_row.id }"
      return nil
    end
    create_sql_diff_header( "#{ self.class.name }: recorded from actions by #{ @current_user }" )

    # Build-up the Meeting:
    meeting = build_meeting( fin_calendar_row )

    # Bail out from session processing if we are requested to:
    if skip_acquired_meetings && meeting.are_results_acquired?
      msg = "Meeting with ACQUIRED results and force update disabled => Skipping SESSION processing...\r\n"
      add_sql_diff_comment( "" )
      add_sql_diff_comment( msg )
      @action_log << "\r\n#{ msg }"
    else
      # (Re-)scan all session DAOs. (Which, allegedly at this point, will refer only
      # to actual meeting events, w/ a possible warm-up time previously set)
      # During the scan, launch the dedicated entity builders and collect a single
      # DB-diff at the end of the loop.
      # (Keep in mind that we may have different pools defined for each compacted
      #  session DAO)
      last_event_order = 0                          # This will allow a single, progressive event ordering among different sessions

      session_daos.each do |dao|
        @action_log << "\r\n\r\n" << "[  New SESSION Begin  ]".center(80, "-") << "\r\n#{ dao }\r\n" << "".center(80, "-") << "\r\n"
# DEBUG
#        puts "\r\n\r\n" << "[  New SESSION Begin  ]".center(80, "-")
#        puts dao.to_s

        # Parse & build pool, city name and address and update the DAO:
        build_pool_with_city_and_address( dao, fin_calendar_row.program_import_text, force_geocoding_search )
        # Current session DAO has any successfully parsed events?
        # (We really do not want to build useless "empty" sessions)
        if dao.meeting_events.count > 0
          meeting_session  = build_session( dao, meeting )
          last_event_order = build_events( dao, meeting_session, last_event_order )
        end
      end
    end

    # Update the source row if it is still unlinked or is linked to a different
    # meeting:
    update_source_calendar_row( fin_calendar_row, meeting ) if fin_calendar_row.meeting_id != meeting.id
                                                    # Create a closing footer:
    create_sql_diff_footer( self.class.name )
    sql_diff_text_log << "\r\n\r\n"
    @action_log << "\r\nScript end."
  end
  #-- -------------------------------------------------------------------------
  #++


  private


  # Sets and launches the internal builder for seeking/building the Meeting possibly
  # associated with the current FIN Calendar row.
  #
  # === Params:
  # - fin_calendar_row: the currently processed FinCalendar row
  #
  # === Returns:
  # The serialized (build or found) Meeting.
  #
  def build_meeting( fin_calendar_row )
    meeting_builder = FinCalendarMeetingBuilder.new( @current_user, fin_calendar_row )
    meeting = meeting_builder.find_or_create!()
    # Append the process log and the DB-diff:
    meeting_builder.report( @action_log, :<< )
# DEBUG
#    meeting_builder.report
    if meeting_builder.has_changes?
      @has_changed_the_db = true
      sql_diff_text_log << meeting_builder.sql_diff_text_log
    end

    meeting
  end
  #-- -------------------------------------------------------------------------
  #++


  # Sets and launches the internal builder for seeking/building the SwimmingPool and
  # the City associated with the current session DAO (which should be already
  # pre-processed by the text parser).
  #
  # The builder sets and updates directly the DAO instance in its members.
  #
  # === Params:
  # - dao: the FinCalendarParseResultDAO currently processed session DAO
  # - full_program_import_text: full text of the meeting program as serialized on the FIN Calendar row being processed
  # - force_geocoding_search: set to true to force the GeoCoding search of all address definitions
  #
  def build_pool_with_city_and_address( dao, full_program_import_text, force_geocoding_search )
    dao.pool_builder = FinCalendarSwimmingPoolBuilder.new(
      @current_user,
      dao,
      full_program_import_text,
      @honor_single_update,
      @geocoder_api_key
    )

    dao.pool_builder.find_or_create!( force_geocoding_search )

    # Append the process log and the DB-diff:
    dao.pool_builder.report( @action_log, :<< )
    if dao.pool_builder.has_changes?
      @has_changed_the_db = true
      sql_diff_text_log << dao.pool_builder.sql_diff_text_log
    end
  end
  #-- -------------------------------------------------------------------------
  #++


  # Sets and launches the internal builder for seeking/building the MeetingSession
  # associated with the current session DAO (which should be already pre-processed
  # by the text parser).
  #
  # === Params:
  # - dao: the FinCalendarParseResultDAO currently processed session DAO
  # - meeting: the currently processed and already serialized Meeting
  #
  # === Returns:
  # The serialized (build or found) MeetingSession.
  #
  def build_session( dao, meeting )
    session_builder = FinCalendarMeetingSessionBuilder.new( @current_user, dao, meeting )
    meeting_session = session_builder.find_or_create!
    # Append the process log and the DB-diff:
    session_builder.report( @action_log, :<< )
# DEBUG
#    session_builder.report
    if session_builder.has_changes?
      @has_changed_the_db = true
      sql_diff_text_log << session_builder.sql_diff_text_log
    end

    meeting_session
  end
  #-- -------------------------------------------------------------------------
  #++


  # Sets and launches the internal builder for seeking/building all the MeetingEvent(s)
  # associated with the current session DAO (which should be already pre-processed
  # by the text parser).
  #
  # === Params:
  # - dao: the FinCalendarParseResultDAO currently processed session DAO
  # - meeting_session: the currently processed and already serialized MeetingSession
  # - last_event_order: the event_order of the last MeetingEvent found or built.
  #
  # === Returns:
  # The currently set (last) event_order.
  #
  def build_events( dao, meeting_session, last_event_order )
    event_builder = FinCalendarMeetingEventBuilder.new( @current_user, dao, meeting_session, last_event_order )
    event_builder.find_or_create!
                                                # Update the last_event_order for the loop:
    last_event_order = event_builder.last_event_order
    # Append the process log and the DB-diff:
    event_builder.report( @action_log, :<< )
    if event_builder.has_changes?
      @has_changed_the_db = true
      sql_diff_text_log << event_builder.sql_diff_text_log
    end

    last_event_order
  end
  #-- -------------------------------------------------------------------------
  #++


  # Sets the Meeting ID into the FIN Calendar row specified, logging the process.
  #
  def update_source_calendar_row( fin_calendar_row, meeting )
    fin_calendar_row.meeting_id = meeting.id
    @action_log << "Updating fin_calendar_row with Meeting ID set to #{ meeting.id }..."
    if fin_calendar_row.save
      sql_attributes = { 'meeting_id' => meeting.id }
      sql_diff_text_log << "\r\n"
      sql_diff_text_log << to_sql_update( fin_calendar_row, false, sql_attributes, "\r\n" )
      @edited_rows_codes << "#{ fin_calendar_row.goggles_meeting_code }/#{ fin_calendar_row.id }"
      @has_changed_the_db = true
    else
      sql_diff_text_log << "-- UPDATE VALIDATION FAILURE during FinCalendar Phase-3: #{ ValidationErrorTools.recursive_error_for( fin_calendar_row ) }\r\n" if fin_calendar_row.invalid?
      sql_diff_text_log << "-- UPDATE FAILURE: #{ $! }\r\n" if $!
      @error_rows_codes << "#{ fin_calendar_row.goggles_meeting_code }/#{ fin_calendar_row.id }"
      @action_log << "UPDATE VALIDATION FAILURE during FinCalendar Phase-3!"
    end
  end
  #-- -------------------------------------------------------------------------
  #++
end