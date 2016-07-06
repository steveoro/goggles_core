require 'wrappers/timing'

#
# == SeasonCreator
#
# Collection of functions used for ceating a new season based on an older one
# When creating new season should consider:
# - season
# - category_types
# - meetings (with sessions and events)
#
# @author   Leega
# @version  4.00.829
#
class SeasonCreator
  include SqlConvertable

  # These can be edited later on:
  attr_accessor :older_season, :description, :new_id, :begin_date, :end_date, :header_year, :edition, 
                :new_season, :categories, :meetings, :meeting_sessions, :meeting_events

  # Initialization
  #
  # == Params:
  # An instance of season used as base for the new one
  #
  def initialize( older_season, description )
    unless older_season && older_season.instance_of?( Season )
      raise ArgumentError.new("Needs the older season to use as model")
    end
    unless description && description.instance_of?( String )
      raise ArgumentError.new("Needs the new season description")
    end
    @older_season = older_season
    @description  = description
    
    @new_id       = older_season.id + 10
    @begin_date   = older_season.begin_date.next_year
    @end_date     = older_season.end_date.next_year
    @header_year  = SeasonCreator.next_header_year( older_season.header_year ) 
    @edition      = older_season.edition + 1 

    if Season.exists?( @new_id )
      raise ArgumentError.new("Season " + @older_season.description + " already duplicated")
    end

    @new_season       = nil
    @categories       = []
    @meetings         = []
    @meeting_sessions = []
    @meeting_events   = []
  end
  #-- --------------------------------------------------------------------------
  #++

  # Prepare data for duplication
  # 
  def prepare_new_season
    create_sql_diff_header( "Duplicating season #{@older_season.id}-#{@older_season.description} into #{@new_id}-#{@description}" )
    @new_season = renew_season
    @categories = renew_categories
    @meetings   = renew_meetings
    create_sql_diff_footer( "#{@new_id}-#{@description} duplication done" )
  end

  # Retreive older season categories and prepare them
  # for the new season
  # 
  def renew_season
    sql_diff_text_log << "-- Season\r\n"
    newer_season = Season.new( @older_season.attributes.reject{ |e| ['lock_version','created_at','updated_at'].include?(e) } )
    newer_season.id          = @new_id
    newer_season.description = @description
    newer_season.begin_date  = @begin_date
    newer_season.end_date    = @end_date
    newer_season.header_year = @header_year
    newer_season.edition     = @edition
    newer_season.rules       = nil
    newer_season.save
    sql_diff_text_log << to_sql_insert( newer_season, false, "\r\n\r\n" ) # no additional comment
    newer_season
  end

  # Retreive older season categories and prepare them
  # for the new season
  # No particular change required to category types data 
  # just associate with new season
  # 
  def renew_categories
    newer_categories = []
    sql_diff_text_log << "-- Categories\r\n"
    @older_season.category_types.each do |category_type|
      newer_category = CategoryType.new( category_type.attributes.reject{ |e| ['lock_version','created_at','updated_at'].include?(e) } )
      newer_category.season_id = @new_id
      newer_category.save
      sql_diff_text_log << to_sql_insert( newer_category, false, "\r\n" ) # no additional comment
      newer_categories << newer_category
    end
    sql_diff_text_log << "\r\n"
    newer_categories
  end

  # Retreive older season meetings and prepare them
  # for the new season
  # 
  def renew_meetings
    newer_meetings = []
    add_sql_diff_comment( "Meetings" )
    @older_season.meetings.each do |meeting|
      sql_diff_text_log << "-- #{meeting.id}-#{meeting.code} #{meeting.description} #{meeting.header_date}\r\n"
      newer_meeting = Meeting.new( meeting.attributes.reject{ |e| ['lock_version','created_at','updated_at'].include?(e) } )
      newer_meeting.id                   = meeting.id + 1000
      newer_meeting.season_id            = @new_id
      newer_meeting.header_date          = SeasonCreator.next_year_eq_day( newer_meeting.header_date ) 
      newer_meeting.entry_deadline       = SeasonCreator.next_year_eq_day( newer_meeting.entry_deadline )
      newer_meeting.header_year          = SeasonCreator.next_header_year( newer_meeting.header_year )
      newer_meeting.edition              = self.edition + 1 if self.edition
      newer_meeting.are_results_acquired = false
      newer_meeting.is_autofilled        = true
      newer_meeting.has_start_list       = false
      newer_meeting.has_invitation       = false
      newer_meeting.invitation           = nil
      newer_meeting.is_confirmed         = false
      if newer_meeting.save
        sql_diff_text_log << to_sql_insert( newer_meeting, false, "\r\n" ) # no additional comment
        newer_meetings << newer_meeting
  
        # Collect meeting sessions too
        meeting.meeting_sessions.each do |meeting_session|
          newer_session = MeetingSession.new( meeting_session.attributes.reject{ |e| ['lock_version','created_at','updated_at'].include?(e) } )
          newer_session.meeting_id     = newer_meeting.id
          newer_session.scheduled_date = SeasonCreator.next_year_eq_day( newer_session.scheduled_date ) if newer_session.scheduled_date > Date.new()
          newer_session.is_autofilled  = true
          if newer_session.save
            sql_diff_text_log << to_sql_insert( newer_session, false, "\r\n" ) # no additional comment
            @meeting_sessions << newer_session
             
            # Collect meeting events too
            meeting_session.meeting_events.each do |meeting_event|
              newer_event = MeetingEvent.new( meeting_event.attributes.reject{ |e| ['lock_version','created_at','updated_at'].include?(e) } )
              newer_event.meeting_session_id = newer_session.id
              newer_event.is_autofilled      = true
              if newer_event.save
                sql_diff_text_log << to_sql_insert( newer_event, false, "\r\n" ) # no additional comment
                @meeting_events << newer_event
              end
            end
          end
        end
      end
      sql_diff_text_log << "\r\n"
    end
    sql_diff_text_log << "\r\n"
    newer_meetings
  end
  #-- --------------------------------------------------------------------------
  #++

  # Increments header year of the season
  # If header_year is in the format aaaa/aaaa increments both years
  # else increments the numerical corrisponding value
  #
  def self.next_header_year( header_year )
    if header_year.length == 9 
      separator = header_year[4]
      years = header_year.split( separator )
      years[0] = (years[0].to_i + 1 ).to_s
      years[1] = (years[1].to_i + 1 ).to_s
      header_year = years.join( separator )
    else
      if header_year.to_i > 0
        header_year = ( header_year.to_i + 1 ).to_s
      end
    end
    header_year    
  end

  # Increments date of an year and tune it to the equivalent day of week
  # subtracting some days
  #
  def self.next_year_eq_day( date )
    if date
      original_day = date.wday
      date = date.next_year
      until ( date.wday == original_day ) do 
        date = date.prev_day 
      end
    end
    date
  end
end
