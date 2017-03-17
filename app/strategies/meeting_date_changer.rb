require 'wrappers/timing'

#
# == MeetingDateChanger
#
# Utility for meeting data changing
# Allows to move scheduled date
# reflecting changes on the meeting sessions
# - meeting
# - calendar days to move on
#
# @author   Leega
# @version  6.093
#
class MeetingDateChanger
  include SqlConvertable

  # These can be edited later on:
  attr_accessor :meeting, :days_to_move_on, :confirm

  # Initialization
  #
  # == Params:
  # An instance of meeting
  # an amount of days to move meeting header and scheduled date
  #
  def initialize( meeting, days_to_move_on, confirm = false )
    unless meeting && meeting.instance_of?( Meeting )
      raise ArgumentError.new("Needs the meeting to be changed")
    end
    if not meeting.header_date
      raise ArgumentError.new("The meeting hasn't any header date")
    end
    unless days_to_move_on && days_to_move_on.kind_of?( Integer )
      raise ArgumentError.new("Needs the amount of days to move on")
    end

    @meeting         = meeting
    @days_to_move_on = days_to_move_on
    @confirm         = confirm
  end
  #-- --------------------------------------------------------------------------
  #++

  # Set the meeting header date according to the days to move on
  #
  def move_meeting_date!
    sql_attributes = {}
    @meeting.header_date = @meeting.header_date + @days_to_move_on
    @meeting.is_confirmed = true if @confirm
    @meeting.save
    sql_attributes['header_date']  = @meeting.header_date
    sql_attributes['is_confirmed'] = @meeting.is_confirmed if @confirm
    sql_diff_text_log << to_sql_update( @meeting, false, sql_attributes, "\r\n" )
    @meeting.header_date
  end

  # Set the meeting session scheduled date according to the days to move on
  #
  def move_meeting_session_date!( meeting_session )
    sql_attributes = {}
    if meeting_session.scheduled_date
      meeting_session.scheduled_date = meeting_session.scheduled_date + @days_to_move_on
      meeting_session.save
      sql_attributes['scheduled_date'] = meeting_session.scheduled_date
      sql_diff_text_log << to_sql_update( meeting_session, false, sql_attributes, "\r\n" )
    end
    meeting_session.scheduled_date
  end

  # Set the meeting header date according to the days to move on
  #
  def change_dates!
    create_sql_diff_header( "Changing meeting #{@meeting.id}-#{@meeting.code} from #{@meeting.header_date} to #{@meeting.header_date + @days_to_move_on}" )
    move_meeting_date!
    @meeting.meeting_sessions.each do |meeting_session|
      move_meeting_session_date!( meeting_session )
    end
    create_sql_diff_footer( "#{@meeting.id}-#{@meeting.code} date change done" )
  end
  # ----------------------------------------------------------------------------
  #++
end
