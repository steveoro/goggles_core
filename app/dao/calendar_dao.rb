# encoding: utf-8

=begin

= ChampionshipDAO

  - Goggles framework vers.:  4.00.570
  - author: Leega

 DAO class containing the structure for calendar rendering.

=end
class CalendarDAO
 
  class MeetingSessionDAO
    # These must be initialized on creation:
    attr_reader :session_order, :scheduled_date, :warm_up_time, :begin_time, :events_list, :swimming_pool
    #-- -------------------------------------------------------------------------
    #++
  
    # Creates a new instance.
    #
    def initialize( meeting_session )
      @session_order  = meeting_session.session_order
      @scheduled_date = meeting_session.get_scheduled_date
      @warm_up_time   = meeting_session.get_warm_up_time
      @begin_time     = meeting_session.get_begin_time
      @events_list    = meeting_session.get_short_events
      @swimming_pool  = meeting_session.swimming_pool
    end
    #-- -------------------------------------------------------------------------
    #++
  end

  # These must be initialized on creation:
  attr_reader :meeting, :meeting_sessions
  #-- -------------------------------------------------------------------------
  #++

  # Creates a new instance.
  #
  # Needs to  be sure team_scores is an instance of TeamScoreDAO
  # to perform correcto sorting
  #
  def initialize( meeting )
    @meeting = meeting

    # Collect meeting sessions
    @meeting_sessions = []
    meeting.meeting_sessions.sort_by_order.includes(:meeting_programs, :swimming_pool).each do |meeting_session|
      @meeting_sessions << MeetingSessionDAO.new( meeting_session )
    end
    
    # TODO
    # Add attributes to manage notes
    # Automate is_confirmed and other flags
  end
  #-- -------------------------------------------------------------------------
  #++
end
