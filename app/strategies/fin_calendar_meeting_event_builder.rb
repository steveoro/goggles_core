# encoding: utf-8
require 'common/format'

=begin

= FinCalendarMeetingEventBuilder

  - Goggles framework vers.:  6.125
  - author: Steve A.

 Finds or creates all the MeetingEvent rows enlisted in the #meeting_events member
 of the specified parse result DAO.

 This builder assumes a Meeting will only have a SINGLE MeetingEvent for a specific
 type. Thus, the existance search is performed using only the Meeting ID and the
 event type as constraints.

 Whenever a previously existing MeetingEvent row is not found, a new one will be
 created and logged into the internal DB-diff text log.


 === Finder/Builder strategy:

  1. Loop on all Meeting events enlisted in the specified DAO
    1.1 Do a single "Primary" search: seek existing Event, w/ same type:
      1.1.1 Found? => Check for missing data and update the existing row
      1.1.2 Not found? => Create a new MeetingEvent using the provided data
  2. Return the instance (either new or found/updated)

=end
class FinCalendarMeetingEventBuilder < FinCalendarBaseBuilder

  attr_reader :result_meeting_events, :last_event_order

  # Creates a new instance, given the current user that has "recorded" this batch
  # of operations.
  #
  # The last_event_order parameter is used to create progressive event_order numbers
  # among different sessions.
  #
  def initialize( current_user, parse_result_dao, meeting_session, last_event_order = 0 )
    super( current_user )
    raise ArgumentError.new('parse_result_dao must be defined!') unless parse_result_dao.instance_of?( FinCalendarParseResultDAO )
    raise ArgumentError.new('meeting_session must be defined!') unless meeting_session.instance_of?( MeetingSession )
    @source_dao = parse_result_dao
    @meeting_session = meeting_session
    @result_meeting_events = []
    @last_event_order = last_event_order
    create_sql_diff_header( "FinCalendarMeetingEventBuilder recorded from actions by #{ current_user }" )
    add_to_log( "\r\n\t············································\r\n\t···    FinCalendarMeetingEventBuilder    ···\r\n\t············································" )
    add_to_log( "- meeting_session: '#{ @meeting_session.get_full_name }'" )
  end
  #-- -------------------------------------------------------------------------
  #++


  # Finds or creates all the MeetingEvent rows enlisted by the source DAO specified
  # in the constructor.
  #
  # It returns a reference to the internal result_meeting_events list member.
  #
  def find_or_create!()
    event_order = @last_event_order
    @source_dao.meeting_events.each_with_index do |event, index|
      add_to_log( "\r\nProcessing event #{ event.get_full_name }..." )
      event_type_id = if event.instance_of?( MeetingEvent )
        add_to_log( "Previosly detected as event_type_id: #{ event.event_type_id }." )
        event.event_type_id
      elsif event.instance_of?( FinCalendarParseResultDAO::EventTypeDAO )
        event_type = create_new_event_type( event )
        add_to_log( "Created new event_type: #{ event_type.inspect }." )
        event_type.id
      end
                                                    # Prepare MeetingEvent requires:
      meeting_session_id = @meeting_session.id
      event_type_id      = event_type_id
      event_order        += index + 1              # (We'll set the event_order as cumulative among all sessions)

      # [Steve, 20170920] We cannot safely detect the begin time from the start time
      # of the session here. (We need the entries, at least.)
      #
      # So this has been removed permanently from the search below:...
      #
      #    begin_time = @source_dao.start_time_iso_format
      #
      # ...Together with the check for a change in the begin time, which resulted in
      # continuous event updates:
      #
      #    ( begin_time.present? &&
      #     Format.a_time( meeting_event.begin_time ) != Format.a_time( begin_time ) )

                                                    # --- SEARCH #1: find pre-existing event ---
      meeting = @meeting_session.meeting
      add_to_log( "Searching meeting Event n.#{ event_order }: #{ event.get_full_name } (type: #{ event_type_id }) among existing events for meeting #{ meeting.id }..." )
      meeting_event = meeting.meeting_events.where( event_type_id: event_type_id ).first
                                                    # Match found?
      if meeting_event.instance_of?( MeetingEvent )
        add_to_log( "Meeting Event found! => #{ meeting_event.inspect }" )
                                                      # --- UPDATE ---
        # Force update of the found instance with the correct values if there are
        # any differences (except user_id):
        # (If the found MeetingEvent belongs to a different session, it will be "moved"
        # to the one specified in the constructor)
        if ( meeting_event.heat_type_id.to_i < 1 ) ||
           ( meeting_event.meeting_session_id != meeting_session_id )
          meeting_event = update_existing( meeting_event, meeting_session_id, event_order, nil, event_type_id )
        end
                                                    # --- CREATION ---
      else
        meeting_event = create_new( meeting_session_id, event_order, @source_dao.start_time_iso_format, event_type_id )
      end
                                                    # Add the created/updated event row to the list:
      @result_meeting_events << meeting_event
    end

    @last_event_order = event_order
    @result_meeting_events
  end
  #-- -------------------------------------------------------------------------
  #++


  private


  # Creates a new/missing EventType while logging the operation.
  # Returns the created instance.
  #
  def create_new_event_type( event_type_dao )
    add_to_log( "EventType MISSING: #{ event_type_dao }.\r\nCreating a new one..." )
    event_type = event_type_dao.get_suggested_instance()

    # Serialize the creation:
    if event_type.save
      sql_diff_text_log << to_sql_insert( event_type, false, "\r\n" )
      add_to_log( "EventType created and logged.\r\n" )
      @has_created = true
    else
      if event_type.invalid?
        sql_diff_text_log << "-- INSERT VALIDATION FAILURE in FinCalendarMeetingEventBuilder, create_new_event_type: #{ ValidationErrorTools.recursive_error_for( event_type ) }\r\n"
        add_to_log( "INSERT VALIDATION FAILURE: #{ ValidationErrorTools.recursive_error_for( event_type ) }" )
        @has_errors = true
      end
      if $!
        sql_diff_text_log << "-- INSERT FAILURE: #{ $! }\r\n" if $!
        add_to_log( "INSERT FAILURE: #{ $! }" )
        @has_errors = true
      end
    end
    event_type
  end


  # Creates a new MeetingEvent instance add the new instance to the internal list
  # of @result_meeting_events, while logging the operation.
  #
  def create_new( meeting_session_id, event_order, begin_time, event_type_id )
    add_to_log( "MeetingEvent NOT found.\r\nCreating a new one as: n.#{ event_order }, session: #{ meeting_session_id }, type: #{ event_type_id }" )
    result_meeting_event = MeetingEvent.new(
      meeting_session_id: meeting_session_id,
      event_order:        event_order,
      begin_time:         begin_time,
      event_type_id:      event_type_id,
      heat_type_id:       HeatType::FINALS_ID,
      is_out_of_race:     false,
      is_autofilled:      true,
      user_id:            @current_user.id,
      has_separate_gender_start_list:   true,
      has_separate_category_start_list: false
    )

    # Serialize the creation:
    super( result_meeting_event, self.class.name )
    result_meeting_event
  end
  #-- -------------------------------------------------------------------------
  #++


  # Updates the specified existing_meeting_event with new values (assuming it is a valid instance)
  # while logging the operation.
  #
  # This implementation won't update the event_order, since it requires knowledge
  # of all existing meeting sessions, even the ones scheduled at a different date.
  #
  def update_existing( existing_meeting_event, meeting_session_id, event_order, begin_time, event_type_id )
    add_to_log( "\r\nUpdating existing MeetingEvent #{ existing_meeting_event.get_full_name }, session: #{ meeting_session_id } n.#{ event_order }, type: #{ event_type_id }" )
    existing_meeting_event.meeting_session_id = meeting_session_id
    # [Steve, 20170713] It's better not to change the previously found event_order,
    # since most previously existing event rows have a single ordering among all
    # the sessions.
#    existing_meeting_event.event_order    = event_order   if event_order != existing_meeting_event.event_order
    existing_meeting_event.begin_time     = begin_time    if begin_time.present?
    existing_meeting_event.event_type_id  = event_type_id if event_type_id.to_i > 0
    existing_meeting_event.heat_type_id   = HeatType::FINALS_ID if existing_meeting_event.heat_type_id.to_i < 1
    existing_meeting_event.is_out_of_race = false
    existing_meeting_event.is_autofilled  = true
    existing_meeting_event.user_id        = @current_user.id
    existing_meeting_event.has_separate_gender_start_list   = true
    existing_meeting_event.has_separate_category_start_list = false

    sql_attributes = existing_meeting_event.attributes.select do |key|
      [
        'meeting_session_id', 'event_order', 'event_order',
        # [Steve, 20170713] See note above
#        'event_order',
        'event_type_id', 'heat_type_id',
        'is_out_of_race', 'is_autofilled', 'user_id', 'user_id',
        'has_separate_gender_start_list', 'has_separate_category_start_list'
      ].include?( key.to_s )
    end
    # Serialize the update:
    super( existing_meeting_event, sql_attributes, self.class.name )
    existing_meeting_event
  end
  #-- -------------------------------------------------------------------------
  #++
end
