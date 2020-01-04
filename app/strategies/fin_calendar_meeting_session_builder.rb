# encoding: utf-8
require 'common/format'

=begin

= FinCalendarMeetingSessionBuilder

  - Goggles framework vers.:  6.329
  - author: Steve A.

 Finds or creates a MeetingSession instance given the parameters.

 If no existing MeetingSession is found from the parsed source fin_calendar row and the
 given meeting, a new MeetingSession row will be created.


 === Note on rescheduled meetings:

 This builder class assumes the scheduled date won't change.
 (It may update the scheduled time, though.)
 Thus, it will always create new sessions whenever a Meeting has been re-scheduled.

 In case of a rescheduled meeting, the admin should accept the creation of a new
 Meeting row by its dedicated builder, and let the FinCalendar cleaner do its
 job once the previous meeting row has been removed by the synchronized calendar.


 === Finder/Builder strategy:

 1. Extract fields from constructor parameters
 2. 1st search: seek existing session, w/ same scheduled date
     and events (time and order could be nil or different, but the number and
     type of events must be the same)
 3. 2nd search: same as above, but look for any session of the current meeting,
    having same events, event with different dates
 4. Found? => Check for missing data and update the existing row
 5. Not found? => Create a new MeetingSession using the provided data
 6. Return the instance (either new or found/updated)


=end
class FinCalendarMeetingSessionBuilder < FinCalendarBaseBuilder

  attr_reader :result_meeting_session

  # Creates a new instance, given the current user that has "recorded" this batch
  # of operations.
  #
  def initialize( current_user, parse_result_dao, meeting )
    super( current_user )
    raise ArgumentError.new('parse_result_dao must be defined!') unless parse_result_dao.instance_of?( FinCalendarParseResultDAO )
    raise ArgumentError.new('meeting must be defined!') unless meeting.instance_of?( Meeting )
    @source_dao = parse_result_dao
    @meeting = meeting
    @result_meeting_session = nil
    create_sql_diff_header( "FinCalendarMeetingSessionBuilder recorded from actions by #{ current_user }" )
    add_to_log( "\r\n\t~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\r\n\t~~~   FinCalendarMeetingSessionBuilder   ~~~\r\n\t~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~" )
    add_to_log( "- meeting id: '#{ meeting.id }'" )
  end
  #-- -------------------------------------------------------------------------
  #++


  # Finds or creates a MeetingSession instance using the #fin_calendar_row
  # given in the constructor.
  #
  # It always returns a Meeting instance, either pre-existing or newly created.
  #
  def find_or_create!()
    # Bail out if we have already found a result:
    if @result_meeting_session.instance_of?( MeetingSession )
      add_to_log( "\r\nfind_or_create!() re-called. Returning previous meeting_session '#{ @result_meeting_session.get_full_name }'..." )
      return @result_meeting_session
    end
                                                    # Prepare MeetingSession requires:
    scheduled_date    = @source_dao.header_date_iso_format
    session_order     = @source_dao.session_order
    begin_time        = @source_dao.start_time_iso_format
    # The following is seldom given in the source description; it should at least
    # default to 30' prior begin time (see line below):
    warm_up_time      = @source_dao.warmup_time_iso_format
    # warm_up_time = begin_time.to_time - 30 * 60    # (Safe default)
    description       = "FINALS" # it should default to "FINALS"; can't be nil
    swimming_pool_id  = @source_dao.pool_builder.result_swimming_pool.id if @source_dao.pool_builder && @source_dao.pool_builder.result_swimming_pool
    day_part_type_id  = @source_dao.day_part_type_id.to_i
    user_id           = @current_user.id

    expected_event_list = @source_dao.meeting_events.map do |meeting_event|
      if meeting_event.instance_of?( MeetingEvent )
        meeting_event.event_type ? meeting_event.event_type.code : '?'
      else
        meeting_event.get_suggested_instance.code
      end
    end
                                                    # --- SEARCH #1: seek out a perfect match, with SAME events, date, time and day_part ---
    search_by_same_date_time_day_part_and_events( scheduled_date, begin_time, day_part_type_id, expected_event_list )

                                                    # --- SEARCH #2: seek out SAME events, day and just day_part ---
    unless @result_meeting_session.instance_of?( MeetingSession )
      search_by_same_date_day_part_and_events( scheduled_date, day_part_type_id, expected_event_list )
    end
                                                    # --- SEARCH #3: seek out just the SAME events, whenever they are found ---
    unless @result_meeting_session.instance_of?( MeetingSession )
      search_just_by_same_events( expected_event_list )
    end
                                                    # Match found?
    if @result_meeting_session.instance_of?( MeetingSession )
      add_to_log( "Meeting Session found! => #{ @result_meeting_session.inspect }" )
                                                    # --- UPDATE ---
      # Force update of the found instance with the correct values if there are
      # any differences (except user_id):
      if ( begin_time.present? && Format.a_time( @result_meeting_session.begin_time ) != Format.a_time( begin_time ) ) ||
         ( warm_up_time.present? && Format.a_time( @result_meeting_session.warm_up_time ) != Format.a_time( warm_up_time ) ) ||
         ( Format.a_date( @result_meeting_session.scheduled_date ) != Format.a_date( scheduled_date ) ) ||
         ( @result_meeting_session.description != description ) ||
         ( swimming_pool_id && @result_meeting_session.swimming_pool_id.to_i != swimming_pool_id.to_i ) ||
         ( day_part_type_id && @result_meeting_session.day_part_type_id.to_i != day_part_type_id.to_i )
        update_existing( scheduled_date, session_order, warm_up_time, begin_time, description, swimming_pool_id, day_part_type_id )
      end
                                                    # --- CREATION ---
    else
      create_new( scheduled_date, session_order, warm_up_time, begin_time, description, swimming_pool_id, day_part_type_id )
    end

    @result_meeting_session
  end
  #-- -------------------------------------------------------------------------
  #++


  private


  # Performs search #1: everything equal, perfect match.
  # Returns and updates @result_meeting_session.
  #
  def search_by_same_date_time_day_part_and_events( scheduled_date, begin_time, day_part_type_id, expected_event_list )
    add_to_log( "Searching meeting session for meeting #{ @meeting.id } @ #{ scheduled_date }, start: #{ begin_time }, w/ events: #{ expected_event_list.join(', ') }..." )
    # Detect the first existing session for the same meeting having same scheduled_date/time & event list:
    # (This can result in a perfect match or an empty session)
    @result_meeting_session = MeetingSession.where(
      meeting_id:       @meeting.id,
      scheduled_date:   scheduled_date,
      begin_time:       begin_time,
      day_part_type_id: day_part_type_id
    ).detect do |meeting_session|
      current_event_list = meeting_session.meeting_events.map{ |me| me.event_type.code }
      if current_event_list.count > 0
        # Let's check if all the expected events are the only members of the current event list:
        result = expected_event_list.all?{ |event| current_event_list.member?( event ) } &&
                 ( expected_event_list.count == current_event_list.count )
        add_to_log( "Checking if '#{ meeting_session.get_full_name }' contains JUST the events: #{ expected_event_list.join(', ') }... #{ result ? 'OK!' : '!=' }" )
        result
      else
        # Empty event sessions found on same day are good candidates by default:
        add_to_log( "Using empty session '#{ meeting_session.get_full_name }' as candidate." )
        true
      end
    end
  end


  # Performs search #2: everything equal except for the begin time of the session,
  # which remains ignored in this search.
  # Returns and updates @result_meeting_session.
  #
  def search_by_same_date_day_part_and_events( scheduled_date, day_part_type_id, expected_event_list )
    add_to_log( "Searching meeting session for meeting #{ @meeting.id } @ #{ scheduled_date }, w/ events: #{ expected_event_list.join(', ') }..." )
    # Detect the first existing session for the same meeting having same scheduled_date/time & event list:
    # (This can result in a perfect match or an empty session)
    @result_meeting_session = MeetingSession.where(
      meeting_id:       @meeting.id,
      scheduled_date:   scheduled_date,
      day_part_type_id: day_part_type_id
    ).detect do |meeting_session|
      current_event_list = meeting_session.meeting_events.map{ |me| me.event_type.code }
      if current_event_list.count > 0
        # Let's check if all the expected events are the only members of the current event list:
        result = expected_event_list.all?{ |event| current_event_list.member?( event ) } &&
                 ( expected_event_list.count == current_event_list.count )
        add_to_log( "Checking if '#{ meeting_session.get_full_name }' contains JUST the events: #{ expected_event_list.join(', ') }... #{ result ? 'OK!' : '!=' }" )
        result
      else
        # Empty event sessions found on same day are good candidates by default:
        add_to_log( "Using empty session '#{ meeting_session.get_full_name }' as candidate." )
        true
      end
    end
  end


  # Performs search #3: seek out just the SAME events, whenever they are found for
  # the same meeting.
  # Returns and updates @result_meeting_session.
  #
  def search_just_by_same_events( expected_event_list )
    add_to_log( "Searching ANY meeting session for meeting #{ @meeting.id }, containing JUST the events: #{ expected_event_list.join(', ') }..." )
    # Detect any session that has the exact list of events we are expecting:
    # (This can result in a session that has a different date/time, i.e. for
    # updated/delayed or moved sessions)
    @result_meeting_session = MeetingSession.where(
      meeting_id: @meeting.id
    ).detect do |meeting_session|
      current_event_list = meeting_session.meeting_events.map{ |me| me.event_type.code }
      # Let's check if all the expected events are member of the current event list and
      # both arrays have the same number of elements:
      expected_event_list.all?{ |event| current_event_list.member?( event ) } &&
      ( expected_event_list.count == current_event_list.count )
    end
  end
  #-- -------------------------------------------------------------------------
  #++


  # Creates a new MeetingSession instance setting its value to @result_meeting_session
  # while logging the operation.
  #
  def create_new( scheduled_date, session_order, warm_up_time, begin_time, description, swimming_pool_id, day_part_type_id )
    add_to_log( "MeetingSession NOT found.\r\nCreating a new one as: n.#{ session_order }, meeting: #{ @meeting.id } @ #{ scheduled_date }; warm-up: #{ warm_up_time }/ begin: #{ begin_time }; '#{ description }', pool id: #{ swimming_pool_id }, day_part_type_id: #{ day_part_type_id }" )
    @result_meeting_session = MeetingSession.new(
      meeting_id:       @meeting.id,
      scheduled_date:   scheduled_date,
      session_order:    session_order,
      warm_up_time:     warm_up_time,
      begin_time:       begin_time,
      description:      description,
      swimming_pool_id: swimming_pool_id,
      day_part_type_id: day_part_type_id,
      is_autofilled:    true,
      user_id:          @current_user.id
    )

    # Serialize the creation:
    super( @result_meeting_session, self.class.name )
  end
  #-- -------------------------------------------------------------------------
  #++


  # Updates @result_meeting_session with new values (assuming it is a valid instance)
  # while logging the operation.
  #
  def update_existing( scheduled_date, session_order, warm_up_time, begin_time, description, swimming_pool_id, day_part_type_id )
    add_to_log( "\r\nUpdating existing MeetingSession with:n.#{ session_order }, meeting: #{ @meeting.id } @ #{ @result_meeting_session.scheduled_date }; warm-up: #{ warm_up_time }/ begin: #{ begin_time }; '#{ description }', pool id: #{ swimming_pool_id }, day_part_type_id: #{ day_part_type_id }" )
    @result_meeting_session.meeting_id = @meeting.id
    @result_meeting_session.scheduled_date  = scheduled_date
    @result_meeting_session.session_order   = session_order
    @result_meeting_session.warm_up_time    = warm_up_time if warm_up_time.present?
    @result_meeting_session.begin_time      = begin_time   if begin_time.present?
    @result_meeting_session.description     = description
    @result_meeting_session.swimming_pool_id  = swimming_pool_id if swimming_pool_id
    @result_meeting_session.day_part_type_id  = day_part_type_id if day_part_type_id
    @result_meeting_session.is_autofilled = true
    @result_meeting_session.user_id = @current_user.id

    sql_attributes = @result_meeting_session.attributes.select do |key|
      [
        'meeting_id', 'scheduled_date', 'session_order', 'warm_up_time', 'begin_time',
        'description', 'swimming_pool_id', 'day_part_type_id', 'is_autofilled', 'user_id'
      ].include?( key.to_s )
    end
    # Serialize the update:
    super( @result_meeting_session, sql_attributes, self.class.name )
  end
  #-- -------------------------------------------------------------------------
  #++
end
