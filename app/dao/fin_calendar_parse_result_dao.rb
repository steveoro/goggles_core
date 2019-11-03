# frozen_string_literal: true

#
# = FinCalendarParseResultDAO
#
#   - Goggles framework vers.:  6.133
#   - author: Steve A.
#
#  DAO class containing the result data from the parsing of a single meeting session
#  from the FinCalendar meeting invitation text fields.
#
#  The data fields and subclasses contained herein are supposed to be used to update
#  or create Meetings, MeetingSessions and MeetingEvents for the FinCalendar rows,
#  but can be used to store update/creation data for any federations' meeting.
#
#  Each instance of this "parent" DAO should refer just to 1 meeting session, with
#  a single list of events.
#
#  The session is identifyed by the same date and starting time.
#  (That is: different time => different session.)
#
class FinCalendarParseResultDAO

  # DAO class for storing possibly new/missing EventType rows found while parsing
  # MeetingEvents.
  #
  class EventTypeDAO

    attr_reader :stroke_type, :is_a_relay, :is_mixed_gender, :relay_phases, :length_in_meters

    # Creates a new instance given the specified parameters
    #
    def initialize( stroke_type, is_a_relay, is_mixed_gender, relay_phases, length_in_meters )
      raise ArgumentError, 'stroke_type must be a valid StrokeType!' unless stroke_type.instance_of?( StrokeType )
      raise ArgumentError, 'relay_phases and length_in_meters must be valid numbers!' unless relay_phases.to_i > 0 && length_in_meters.to_i > 0

      @stroke_type      = stroke_type
      @is_a_relay       = is_a_relay
      @is_mixed_gender  = is_mixed_gender
      @relay_phases     = relay_phases
      @length_in_meters = length_in_meters
    end

    # Returns the suggested new EventType instance (yet to be saved), given the
    # constructor parameters
    def get_suggested_instance
      # Compose the code:
      code = if is_a_relay
        "#{ is_mixed_gender ? 'M' : 'S' }#{ relay_phases }X#{ length_in_meters }#{ stroke_type.code }"
      else
        "#{ length_in_meters }#{ stroke_type.code }"
      end

      # Style order should be a progressive:
      style_order = EventType.count + 1

      EventType.new(
        code: code,
        stroke_type_id: stroke_type.id,
        is_a_relay: is_a_relay,
        is_mixed_gender: is_mixed_gender,
        phases: relay_phases,
        partecipants: relay_phases, # (This is an educated guess)
        style_order: style_order,
        length_in_meters: length_in_meters * relay_phases,
        phase_length_in_meters: length_in_meters
      )
    end

    # Returns the a string representation of the current instance
    def to_s
      if is_a_relay
        "[#{relay_phases}x#{length_in_meters} #{stroke_type.code}, mixed gender: #{ is_mixed_gender }]"
      else
        "[#{length_in_meters} #{stroke_type.code}]"
      end
    end

    alias get_full_name to_s

  end
  #-- -------------------------------------------------------------------------
  #++

  attr_accessor :date_day_token, :date_month_token, :start_time_token, :warmup_time_token,
                :header_date_iso_format, :start_time_iso_format, :warmup_time_iso_format,
                :day_part_type_id,
                :organization_notes, :reference_name,
                :meeting_place,
                # This parameter is used to store a new pool definition whenever found
                # while parsing the program text. This may happen for Meetings that
                # have multiple pools, defined inside each session program.
                :pool_override_text,
                # These are the 2 main builders set & used externally to create the actual model instances:
                :pool_builder, :session_builder

  attr_reader   :event_tokens,      # List of source event tokens, yet to be parsed into actual values ("50 SL", "50 DO", ...)
                :meeting_events,    # List of actual MeetingEvent / MeetingEventDAO instances, filled by the parsing strategy
                :session_order,     # Progressive ordering integer for this session
                :source_text_line   # Raw source text line used for the parsing of the program, a date or anything else

  # Creates a new instance given the specified parameters
  #
  def initialize( date_day_token, date_month_token, current_session_order, source_text_line )
    @date_day_token   = date_day_token
    @date_month_token = date_month_token
    @source_text_line = source_text_line
    @session_order    = current_session_order
    @event_tokens   = []
    @meeting_events = []
  end
  #-- -------------------------------------------------------------------------
  #++

  # Adds a new item to the list of event tokens for this session
  def add_event_token( text_token )
    @event_tokens << text_token
  end

  # Adds a new item to the list of meeting events for this session
  def add_meeting_event( meeting_event )
    @meeting_events << meeting_event
  end
  #-- -------------------------------------------------------------------------
  #++

  # Returns true if the current session DAO instance contains a Warm-up session.
  # (With no other parsed events, except the warm-up token found.)
  def is_a_warmup?
    (meeting_events.count == 0) && FinCalendarTextParser.contains_a_warmup?( event_tokens.first )
  end
  #-- -------------------------------------------------------------------------
  #++

  # Outputs a String description of the current instance.
  def to_s
    "[n.#{ session_order } #{ date_day_token }/#{ date_month_token } @#{ start_time_token }, W:#{ warmup_time_token.presence || ''}]: #{ event_tokens.join(', ') }, parsed events: #{ meeting_events.count }#{ pool_override_text.present? ? ' - '+pool_override_text : '' }"
  end
  #-- -------------------------------------------------------------------------
  #++

end
