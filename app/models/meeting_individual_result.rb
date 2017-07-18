require 'wrappers/timing'


#
# == MeetingIndividualResult
#
# Model class
#
# @author   Steve A., Leega
# @version  6.111
#
class MeetingIndividualResult < ApplicationRecord
  include SwimmerRelatable
  include TimingGettable
  include TimingValidatable

  include EventTypeRelatable

  belongs_to :user                                  # [Steve, 20120212] Do not validate associated user!

  belongs_to :meeting_program
  validates_associated :meeting_program

  has_one  :meeting_event,    through: :meeting_program
  has_one  :meeting_session,  through: :meeting_program
  has_one  :meeting,          through: :meeting_program
  has_one  :season,           through: :meeting_program
  has_one  :season_type,      through: :season

  has_one  :pool_type,        through: :meeting_program
  has_one  :event_type,       through: :meeting_event
  has_one  :category_type,    through: :meeting_program
  has_one  :gender_type,      through: :meeting_program
  has_one  :federation_type,  through: :season_type

  has_many :passages
                                                    # These reference fields may be filled-in later (thus not validated upon creation):
  belongs_to :team
  belongs_to :team_affiliation
  belongs_to :badge
  belongs_to :disqualification_code_type

  validates_associated :team
  validates_associated :team_affiliation
  validates_associated :badge
  validates_associated :disqualification_code_type

  validates_presence_of     :rank
  validates_length_of       :rank, within: 1..4, allow_nil: false
  validates_numericality_of :rank

  validates_presence_of     :standard_points
  validates_numericality_of :standard_points
  validates_presence_of     :meeting_individual_points
  validates_numericality_of :meeting_individual_points
  validates_presence_of     :goggle_cup_points
  validates_numericality_of :goggle_cup_points
  validates_presence_of     :team_points
  validates_numericality_of :team_points

  validates_presence_of     :reaction_time
  validates_numericality_of :reaction_time


# FIXME for Rails 4+, move required/permitted check to the controller using the model
#  attr_accessible :rank, :is_play_off, :is_out_of_race, :is_disqualified, :standard_points,
#                  :meeting_individual_points, :minutes, :seconds, :hundreds,
#                  :meeting_program_id, :swimmer_id, :team_id, :badge_id, :user_id,
#                  :disqualification_code_type_id, :goggle_cup_points, :reaction_time,
#                  :team_points, :team_affiliation_id, :is_personal_best


  delegate :short_name, to: :category_type, prefix: true
  delegate :code,       to: :event_type, prefix: true

  scope :is_valid,                    -> { where(is_out_of_race: false, is_disqualified: false) }
  scope :is_not_disqualified,         -> { where(is_disqualified: false) }
  scope :is_disqualified,             -> { where(is_disqualified: true) }
  scope :is_personal_best,            -> { where(is_personal_best: true) }
  scope :is_season_type_best,         -> { where(is_season_type_best: true) }

  scope :is_male,                     -> { joins(:swimmer).where(["swimmers.gender_type_id = ?", GenderType::MALE_ID]) }
  scope :is_female,                   -> { joins(:swimmer).where(["swimmers.gender_type_id = ?", GenderType::FEMALE_ID]) }

  scope :has_rank,                    ->(rank_filter) { where(rank: rank_filter) }
  scope :has_points,                  ->(score_sym = 'standard_points') { where("#{score_sym.to_s} > 0") }
  scope :has_time,                    -> { where("((minutes * 6000) + (seconds * 100) + hundreds > 0)") }

  scope :sort_by_user,                ->(dir = 'ASC') { order("users.name #{dir.to_s}, meeting_programs.meeting_session_id #{dir.to_s}, swimmers.last_name #{dir.to_s}, swimmers.first_name #{dir.to_s}") }
  scope :sort_by_meeting,             ->(dir)         { order("meeting_programs.meeting_session_id #{dir.to_s}, swimmers.last_name #{dir.to_s}, swimmers.first_name #{dir.to_s}") }
  scope :sort_by_swimmer,             ->(dir = 'ASC') { joins(:swimmer).order("swimmers.complete_name #{dir.to_s}, meeting_individual_results.rank #{dir.to_s}") }
  scope :sort_by_team,                ->(dir = 'ASC') { joins(:team, :swimmer).order("teams.name #{dir.to_s}, swimmers.complete_name #{dir.to_s}") }
  scope :sort_by_badge,               ->(dir = 'ASC') { joins(:badge).order("badges.number #{dir.to_s}") }
  scope :sort_by_timing,              ->(dir = 'ASC') { order("is_disqualified, (hundreds+(seconds*100)+(minutes*6000)) #{dir.to_s}") }
  scope :sort_by_rank,                ->(dir = 'ASC') { order("is_disqualified, rank #{dir.to_s}") }
  scope :sort_by_date,                ->(dir = 'ASC') { includes(:meeting_session).order("meeting_sessions.scheduled_date #{dir.to_s}") }
  scope :sort_by_goggle_cup,          ->(dir = 'DESC') { order("goggle_cup_points #{dir.to_s}") }
  scope :sort_by_standard_points,     ->(dir = 'DESC') { order("standard_points #{dir.to_s}") }
  scope :sort_by_pool_and_event,      ->(dir = 'ASC') { joins(:event_type, :pool_type).order("pool_types.length_in_meters #{dir.to_s}, event_types.style_order #{dir.to_s}") }
  scope :sort_by_gender_and_category, ->(dir = 'ASC') { joins(:gender_type, :category_type).order("gender_types.code #{dir.to_s}, category_types.code #{dir.to_s}") }
  scope :sort_by_updated_at,          ->(dir = 'ASC') { order("updated_at #{dir.to_s}") }
  scope :sort_by_event_order,         ->(dir = 'ASC') { includes(:meeting_event, :meeting_session).order("(meeting_sessions.session_order*100)+meeting_events.event_order #{dir.to_s}") }
  scope :sort_by_event_and_timing,    ->(dir = 'ASC') { includes(:meeting_event, :meeting_session).order("(meeting_sessions.session_order*100)+meeting_events.event_order #{dir.to_s}, is_disqualified, (hundreds+(seconds*100)+(minutes*6000)) DESC") }

  scope :for_event_by_pool_type,      ->(event_by_pool_type)   { joins(:event_type, :pool_type).where(["event_types.id = ? AND pool_types.id = ?", event_by_pool_type.event_type_id, event_by_pool_type.pool_type_id]) }
  scope :for_pool_type,               ->(pool_type)            { joins(:pool_type).where(['pool_types.id = ?', pool_type.id]) }
  scope :for_season_type,             ->(season_type)          { joins(:season_type).where(['season_types.id = ?', season_type.id]) }
  scope :for_team,                    ->(team)                 { where(team_id: team.id) }
  scope :for_category_type,           ->(category_type)        { joins(:category_type).where(['category_types.id = ?', category_type.id]) }
  scope :for_gender_type,             ->(gender_type)          { joins(:gender_type).where(['gender_types.id = ?', gender_type.id]) }
  scope :for_event_type,              ->(event_type)           { joins(:event_type).where(["event_types.id = ?", event_type.id]) }
  scope :for_swimmer,                 ->(swimmer)              { where(swimmer_id: swimmer.id) }
  scope :for_category_code,           ->(category_code)        { joins(:category_type).where(['category_types.code = ?', category_code]) }
  scope :for_date_range,              ->(date_begin, date_end) { joins(:meeting).where(['meetings.header_date between ? and ?', date_begin, date_end]) }
  scope :for_season,                  ->(season)               { joins(:season).where(['seasons.id = ?', season.id]) }
  scope :for_closed_seasons,          -> { joins(:season).where("seasons.end_date is not null and seasons.end_date < curdate()") }
  scope :for_over_that_score,         ->(score_sym = 'standard_points', points = 800) { where("#{score_sym.to_s} > #{points}") }
  scope :for_meeting_editions,        ->(meeting)              { joins(:meeting).where(['meetings.code = ?', meeting.code]) }

  # ----------------------------------------------------------------------------
  # Base methods:
  # ----------------------------------------------------------------------------
  #++

  # Computes a shorter description for the name associated with this data
  def get_full_name
    "#{get_scheduled_date} #{get_event_type}: #{rank}) #{get_swimmer_name}, #{get_timing}"
  end

  # Computes a verbose or formal description for the name associated with this data
  def get_verbose_name
    "#{get_meeting_program_verbose_name}: #{rank}) #{get_swimmer_name} (#{get_year_of_birth}), #{get_timing}"
  end

  # Retrieves the user name associated with this instance
  def user_name
    self.user ? self.user.name : ''
  end
  # ----------------------------------------------------------------------------

  # Check if this result is valid for the ranking system.
  def is_valid_for_ranking
    !(
      (meeting_event && meeting_event.is_out_of_race) ||
      (meeting_program && meeting_program.is_out_of_race) ||
      self.is_out_of_race ||
      self.is_disqualified
    )
  end

  # Retrieves the associated Team full name
  def get_team_name
    self.team ? self.team.get_full_name() : '?'
  end
  # ----------------------------------------------------------------------------

  # Retrieves the Category Type id as it is; returns 0 in case of an invalid record
  def get_category_type_id
    self.category_type ? self.category_type.id : 0
  end

  # Retrieves the Category Type code as it is; returns '?' in case of an invalid record
  def get_category_type_code
    self.category_type ? self.category_type.code : '?'
  end

  # Retrieves the Category Type short name as it is; returns '?' in case of an invalid record
  def get_category_type_short_name
    self.category_type ? self.category_type.short_name : '?'
  end
  # ----------------------------------------------------------------------------

  # Retrieves the Season id as it is; returns 0 in case of an invalid record
  def get_season_id
    self.season ? self.season.id : 0
  end

  # Retrieves the Gender Type id as it is; returns 0 in case of an invalid record
  def get_gender_type_id
    self.gender_type ? self.gender_type.id : 0
  end

  # Retrieves the Pool Type id as it is; returns 0 in case of an invalid record
  def get_pool_type_id
    self.pool_type ? self.pool_type.id : 0
  end

  # Computes the event by pool type code
  def get_event_by_pool_type_code
    self.pool_type && self.event_type ? "#{self.event_type.code}-#{self.pool_type.code}" : '?'
  end

  # Retrieves the event by pool type; returns nil in case of an invalid record
  def get_event_by_pool_type
    EventsByPoolType.find_by_key( self.get_event_by_pool_type_code  )
  end
  # ----------------------------------------------------------------------------

  # Getter for short display name of Category + Gender.
  def get_category_and_gender_short
    self.meeting_program ? self.meeting_program.get_category_and_gender_short : '?'
  end

  # Retrieves the scheduled_date of this result
  def get_scheduled_date                            # The following ActiveRecord chain is granted in existence by validation assertions: (even the first check could be avoided)
    self.meeting_program ? self.meeting_program.meeting_session.scheduled_date : '?'
  end

  # Retrieves the Meeting Program short name
  def get_meeting_program_name
    self.meeting_program ? self.meeting_program.get_full_name() : '?'
  end

  # Retrieves the Meeting Program verbose name
  def get_meeting_program_verbose_name
    self.meeting_program ? self.meeting_program.get_verbose_name() : '?'
  end
  #-- --------------------------------------------------------------------------
  #++

  # Returns +true+ if this instance is associated to the specified PoolType#code.
  # +false+ otherwise. Code-equality test (w/ safety) checker.
  def has_pool_type_code?( code )
     pool_type ? pool_type.code == code : false
  end

  # Returns +true+ if this instance is associated to the specified EventType#code.
  # +false+ otherwise. Code-equality test (w/ safety) checker.
  def has_event_type_code?( code )
     event_type ? event_type.code == code : false
  end

  # Returns +true+ if this instance is associated to the specified CategoryType#code.
  # +false+ otherwise. Code-equality test (w/ safety) checker.
  def has_category_type_code?( code )
     category_type ? category_type.code == code : false
  end

  # Returns +true+ if this instance is associated to the specified GenderType#code.
  # +false+ otherwise. Code-equality test (w/ safety) checker.
  def has_gender_type_code?( code )
     gender_type ? gender_type.code == code : false
  end

  # Returns +true+ if this instance is associated to the specified GenderType#code.
  # +false+ otherwise. Code-equality test (w/ safety) checker.
  def has_federation_type_code?( code )
     federation_type ? federation_type.code == code : false
  end
  #-- --------------------------------------------------------------------------
  #++

  # Safe getter to retrieve the associated sorted list of passages.
  # Returns an empty array when none are found.
  # (User #get_passages.count to get the total number of passages.)
  #
  def get_passages
    passages ? passages.sort_by_distance : []
  end
  #-- --------------------------------------------------------------------------
  #++

  # Calculate the swimemr age
  def get_swimmer_age
    get_scheduled_date.year - swimmer.year_of_birth + ( get_scheduled_date.month > 9 ? 1 : 0 )
  end
end
