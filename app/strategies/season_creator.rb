# frozen_string_literal: true

require 'wrappers/timing'

#
# == SeasonCreator
#
#   - Goggles framework vers.:  6.093
#   - author: Leega, Steve A.
#
#  Collection of functions used for ceating a new season based on an older one
#  When creating new season should consider:
#  - season
#  - category_types
#  - meetings (with sessions and events)
#
class SeasonCreator

  include SqlConvertable

  # These can be edited later on:
  attr_accessor :older_season, :description, :new_id, :begin_date, :end_date, :header_year, :edition,
                :new_season, :categories, :meetings, :meeting_sessions, :meeting_events

  # Creator.
  # It will try to add a new Season at a specific ID step interval from the previous one.
  # When available, it wll use a prefixed step of 10 for ID increments; otherwise,
  # the first free ID will be chosen.
  #
  # == Params:
  # An instance of season used as base for the new one
  #
  def initialize(older_season, description)
    raise ArgumentError, 'Needs the older season to use as model' unless older_season&.instance_of?(Season)
    raise ArgumentError, 'Needs the new season description' unless description&.instance_of?(String)

    @older_season = older_season
    @description  = description

    @new_id       = find_new_free_id_for_season(older_season.id + 10)
    @begin_date   = older_season.begin_date.next_year
    @end_date     = older_season.end_date.next_year
    @header_year  = SeasonCreator.next_header_year(older_season.header_year)
    @edition      = older_season.edition + 1

    # TODO: REMOVE THIS. It should never occur anymore with the added helper finder method find_new_free_id_for_season
    #    if Season.exists?( @new_id )
    #      raise ArgumentError.new("Season " + @older_season.description + " already duplicated")
    #    end

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
  def prepare_new_season!(prepare_meetings = true)
    create_sql_diff_header("Duplicating season #{@older_season.id}-#{@older_season.description} into #{@new_id}-#{@description}")
    @new_season = renew_season!
    @categories = renew_categories!
    @meetings   = renew_meetings! if prepare_meetings
    create_sql_diff_footer("#{@new_id}-#{@description} duplication done")
  end

  # Retreive older season categories and prepare them
  # for the new season
  #
  def renew_season!
    sql_diff_text_log << "-- Season\r\n"
    newer_season = Season.new(@older_season.attributes.reject { |e| %w[id lock_version created_at updated_at].include?(e) })
    newer_season.id          = @new_id
    newer_season.description = @description
    newer_season.begin_date  = @begin_date
    newer_season.end_date    = @end_date
    newer_season.header_year = @header_year
    newer_season.edition     = @edition
    newer_season.rules       = nil
    newer_season.save
    sql_diff_text_log << to_sql_insert(newer_season, false, "\r\n\r\n") # no additional comment
    newer_season
  end

  # Retreive older season categories and prepare them
  # for the new season
  # No particular change required to category types data
  # just associate with new season
  #
  def renew_categories!
    newer_categories = []
    sql_diff_text_log << "-- Categories\r\n"
    @older_season.category_types.each do |category_type|
      newer_category = CategoryType.new(category_type.attributes.reject { |e| %w[id lock_version created_at updated_at].include?(e) })
      newer_category.season_id = @new_id
      newer_category.save
      sql_diff_text_log << to_sql_insert(newer_category, false, "\r\n") # no additional comment
      newer_categories << newer_category
    end
    sql_diff_text_log << "\r\n"
    newer_categories
  end

  # Retreive older season meetings and prepare them
  # for the new season
  #
  def renew_meetings!
    newer_meetings = []
    add_sql_diff_comment('Meetings')
    @older_season.meetings.each do |meeting|
      sql_diff_text_log << "-- #{meeting.id}-#{meeting.code} #{meeting.description} #{meeting.header_date}\r\n"
      newer_meeting = Meeting.new(meeting.attributes.reject { |e| %w[id lock_version created_at updated_at].include?(e) })
      newer_meeting.id                   = meeting.id + 1000
      newer_meeting.season_id            = @new_id
      newer_meeting.header_date          = SeasonCreator.next_year_eq_day(newer_meeting.header_date)
      newer_meeting.entry_deadline       = SeasonCreator.next_year_eq_day(newer_meeting.entry_deadline)
      newer_meeting.header_year          = SeasonCreator.next_header_year(newer_meeting.header_year)
      newer_meeting.edition              = edition + 1 if edition
      newer_meeting.are_results_acquired = false
      newer_meeting.is_autofilled        = true
      newer_meeting.has_start_list       = false
      newer_meeting.has_invitation       = false
      newer_meeting.invitation           = nil
      newer_meeting.is_confirmed         = false
      if newer_meeting.save
        sql_diff_text_log << to_sql_insert(newer_meeting, false, "\r\n") # no additional comment
        newer_meetings << newer_meeting

        # Collect meeting sessions too
        meeting.meeting_sessions.each do |meeting_session|
          newer_session = MeetingSession.new(meeting_session.attributes.reject { |e| %w[id lock_version created_at updated_at].include?(e) })
          newer_session.meeting_id     = newer_meeting.id
          newer_session.scheduled_date = SeasonCreator.next_year_eq_day(newer_session.scheduled_date) if newer_session.scheduled_date && newer_session.scheduled_date > Date.new
          newer_session.is_autofilled  = true
          next unless newer_session.save

          sql_diff_text_log << to_sql_insert(newer_session, false, "\r\n") # no additional comment
          @meeting_sessions << newer_session

          # Collect meeting events too
          meeting_session.meeting_events.each do |meeting_event|
            newer_event = MeetingEvent.new(meeting_event.attributes.reject { |e| %w[id lock_version created_at updated_at].include?(e) })
            newer_event.meeting_session_id = newer_session.id
            newer_event.is_autofilled      = true
            if newer_event.save
              sql_diff_text_log << to_sql_insert(newer_event, false, "\r\n") # no additional comment
              @meeting_events << newer_event
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
  def self.next_header_year(header_year, increment = 1)
    if header_year.length == 9
      separator = header_year[4]
      years = header_year.split(separator)
      years[0] = (years[0].to_i + increment).to_s
      years[1] = (years[1].to_i + increment).to_s
      header_year = years.join(separator)
    else
      header_year = (header_year.to_i + increment).to_s if header_year.to_i > 0
    end
    header_year
  end

  # Increments date of an year and tune it to the equivalent day of week
  # subtracting some days
  #
  def self.next_year_eq_day(date, increment = 1)
    if date
      original_day = date.wday
      date = date.next_year(increment)
      date = date.prev_day until date.wday == original_day
    end
    date
  end

  private

  # Loops starting from the specified ID value in search of a free ID
  # to return
  def find_new_free_id_for_season(starting_id)
    last_season_found = Season.where(['id > ?', starting_id - 1]).select(:id).last
    if last_season_found
      last_season_found.id + 1
    else
      starting_id
    end
  end

end
