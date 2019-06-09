# frozen_string_literal: true

require 'wrappers/timing'

#
# == MeetingIndividualResult
#
# Model class
#
# @author   Steve A., Leega
# @version  6.334
#
# rubocop:disable Rails/DynamicFindBy
class MeetingIndividualResult < ApplicationRecord

  include SwimmerRelatable
  include TimingGettable
  include TimingValidatable

  include EventTypeRelatable

  belongs_to :user # [Steve, 20120212] Do not validate associated user!

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
  has_one  :stroke_type,      through: :event_type

  has_many :passages, -> { order(:passage_type_id) }
  # These reference fields may be filled-in later (thus not validated upon creation):
  belongs_to :team
  belongs_to :team_affiliation
  belongs_to :badge
  belongs_to :disqualification_code_type

  validates_associated :team
  validates_associated :team_affiliation
  validates_associated :badge
  validates_associated :disqualification_code_type

  validates :rank, presence: true
  validates :rank, length: { within: 1..4, allow_nil: false }
  validates :rank, numericality: true

  validates :standard_points, presence: true
  validates :standard_points, numericality: true
  validates :meeting_individual_points, presence: true
  validates :meeting_individual_points, numericality: true
  validates :goggle_cup_points, presence: true
  validates :goggle_cup_points, numericality: true
  validates :team_points, presence: true
  validates :team_points, numericality: true

  validates :reaction_time, presence: true
  validates :reaction_time, numericality: true

  delegate :short_name, to: :category_type, prefix: true
  delegate :code,       to: :event_type, prefix: true

  scope :is_valid,                    -> { where(is_out_of_race: false, is_disqualified: false) }
  scope :is_not_disqualified,         -> { where(is_disqualified: false) }
  scope :is_disqualified,             -> { where(is_disqualified: true) }
  scope :is_personal_best,            -> { where(is_personal_best: true) }
  scope :is_season_type_best,         -> { where(is_season_type_best: true) }

  scope :is_male,                     -> { joins(:swimmer).where(['swimmers.gender_type_id = ?', GenderType::MALE_ID]) }
  scope :is_female,                   -> { joins(:swimmer).where(['swimmers.gender_type_id = ?', GenderType::FEMALE_ID]) }

  scope :has_rank,                    ->(rank_filter) { where(rank: rank_filter) }
  scope :has_points,                  ->(score_sym = 'standard_points') { where("#{score_sym} > 0") }

  # [Steve, 20180613] Do not change the scope below with a composite check on each field joined by 'AND's, because it does not work
  scope :has_time,                    -> { where('(minutes + seconds + hundreds > 0)') }

  scope :sort_by_user,                ->(dir = 'ASC') { order("users.name #{dir}, meeting_programs.meeting_session_id #{dir}, swimmers.last_name #{dir}, swimmers.first_name #{dir}") }
  scope :sort_by_meeting,             ->(dir)         { order("meeting_programs.meeting_session_id #{dir}, swimmers.last_name #{dir}, swimmers.first_name #{dir}") }
  scope :sort_by_swimmer,             ->(dir = 'ASC') { joins(:swimmer).order("swimmers.complete_name #{dir}, meeting_individual_results.rank #{dir}") }
  scope :sort_by_team,                ->(dir = 'ASC') { joins(:team, :swimmer).order("teams.name #{dir}, swimmers.complete_name #{dir}") }
  scope :sort_by_badge,               ->(dir = 'ASC') { joins(:badge).order("badges.number #{dir}") }
  scope :sort_by_timing,              ->(dir = 'ASC') { order(is_disqualified: :asc, minutes: dir.to_s.downcase.to_sym, seconds: dir.to_s.downcase.to_sym, hundreds: dir.to_s.downcase.to_sym) }
  scope :sort_by_rank,                ->(dir = 'ASC') { order(is_disqualified: :asc, rank: dir.to_s.downcase.to_sym) }
  scope :sort_by_date,                ->(dir = 'ASC') { joins(:meeting_session).order("meeting_sessions.scheduled_date #{dir}") }
  scope :sort_by_goggle_cup,          ->(dir = 'DESC') { order(goggle_cup_points: dir.to_s.downcase.to_sym) }
  scope :sort_by_standard_points,     ->(dir = 'DESC') { order(standard_points: dir.to_s.downcase.to_sym) }
  scope :sort_by_pool_and_event,      ->(dir = 'ASC') { joins(:event_type, :pool_type).order("pool_types.length_in_meters #{dir}, event_types.style_order #{dir}") }
  scope :sort_by_gender_and_category, ->(dir = 'ASC') { joins(:gender_type, :category_type).order("gender_types.code #{dir}, category_types.code #{dir}") }
  scope :sort_by_updated_at,          ->(dir = 'ASC') { order("updated_at #{dir}") }

  scope :sort_by_event_order,         lambda { |_dir = 'ASC'|
    joins(:meeting_program, :meeting_event, :meeting_session)
      .includes(:meeting_event, :meeting_session)
      .order('meeting_sessions.session_order #{dir.to_s}', 'meeting_events.event_order #{dir.to_s}')
  }

  scope :sort_by_event_and_timing, lambda { |_dir = 'ASC'|
    joins(:meeting_program, :meeting_event, :meeting_session)
      .includes(:meeting_event, :meeting_session)
      .order('meeting_sessions.session_order #{dir.to_s}', 'meeting_events.event_order #{dir.to_s}', :is_disqualified, :minutes, :seconds, :hundreds)
  }

  scope :for_event_by_pool_type,      ->(event_by_pool_type)   { joins(:event_type, :pool_type).where(['event_types.id = ? AND pool_types.id = ?', event_by_pool_type.event_type_id, event_by_pool_type.pool_type_id]) }
  scope :for_pool_type,               ->(pool_type)            { joins(:pool_type).where(['pool_types.id = ?', pool_type.id]) }
  scope :for_season_type,             ->(season_type)          { joins(:season_type).where(['season_types.id = ?', season_type.id]) }
  scope :for_team,                    ->(team)                 { where(team_id: team.id) }
  scope :for_category_type,           ->(category_type)        { joins(:category_type).where(['category_types.id = ?', category_type.id]) }
  scope :for_gender_type,             ->(gender_type)          { joins(:gender_type).where(['gender_types.id = ?', gender_type.id]) }
  scope :for_event_type,              ->(event_type)           { joins(:event_type).where(['event_types.id = ?', event_type.id]) }
  scope :for_swimmer,                 ->(swimmer)              { where(swimmer_id: swimmer.id) }
  scope :for_category_code,           ->(category_code)        { joins(:category_type).where(['category_types.code = ?', category_code]) }
  scope :for_date_range,              ->(date_begin, date_end) { joins(:meeting).where(['meetings.header_date between ? and ?', date_begin, date_end]) }
  scope :for_season,                  ->(season)               { joins(:season).where(['seasons.id = ?', season.id]) }
  scope :for_closed_seasons,          -> { joins(:season).where('seasons.end_date is not null and seasons.end_date < curdate()') }
  scope :for_over_that_score,         ->(score_sym = 'standard_points', points = 800) { where("#{score_sym} > #{points}") }
  scope :for_meeting_editions,        ->(meeting) { joins(:meeting).where(['meetings.code = ?', meeting.code]) }

  # scope :for_team_best,               ->(pool_type, gender_type, category_code, event_type) { joins(:meeting_program, :meeting_event, :category_type).where(['meeting_programs.pool_types_id = ? and meeting_programs.gender_types_id = ? and category_types.code = ? and meeting_events.event_types_id = ?', pool_type.id, gender_type.id, category_code, event_type.id]) }
  scope :for_team_best,               ->(pool_type, gender_type, category_code, event_type) { joins(meeting_program: [:category_type, :meeting_event]).where(['meeting_programs.pool_type_id = ? and meeting_programs.gender_type_id = ? and category_types.code = ? and meeting_events.event_type_id = ?', pool_type.id, gender_type.id, category_code, event_type.id]) }

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
    user ? user.name : ''
  end
  # ----------------------------------------------------------------------------

  # Check if this result is valid for the ranking system.
  def is_valid_for_ranking
    !(
      (meeting_event && meeting_event.is_out_of_race) ||
      (meeting_program && meeting_program.is_out_of_race) ||
      is_out_of_race ||
      is_disqualified
    )
  end

  # Retrieves the associated Team full name
  def get_team_name
    team ? team.get_full_name : '?'
  end
  # ----------------------------------------------------------------------------

  # Retrieves the Category Type id as it is; returns 0 in case of an invalid record
  def get_category_type_id
    category_type ? category_type.id : 0
  end

  # Retrieves the Category Type code as it is; returns '?' in case of an invalid record
  def get_category_type_code
    category_type ? category_type.code : '?'
  end

  # Retrieves the Category Type short name as it is; returns '?' in case of an invalid record
  def get_category_type_short_name
    category_type ? category_type.short_name : '?'
  end
  # ----------------------------------------------------------------------------

  # Retrieves the Season id as it is; returns 0 in case of an invalid record
  def get_season_id
    season ? season.id : 0
  end

  # Retrieves the Gender Type id as it is; returns 0 in case of an invalid record
  def get_gender_type_id
    gender_type ? gender_type.id : 0
  end

  # Retrieves the Pool Type id as it is; returns 0 in case of an invalid record
  def get_pool_type_id
    pool_type ? pool_type.id : 0
  end

  # Computes the event by pool type code
  def get_event_by_pool_type_code
    pool_type && event_type ? "#{event_type.code}-#{pool_type.code}" : '?'
  end

  # Retrieves the event by pool type; returns nil in case of an invalid record
  def get_event_by_pool_type
    EventsByPoolType.find_by_key(get_event_by_pool_type_code)
  end
  # ----------------------------------------------------------------------------

  # Getter for short display name of Category + Gender.
  def get_category_and_gender_short
    meeting_program ? meeting_program.get_category_and_gender_short : '?'
  end

  # Retrieves the scheduled_date of this result
  def get_scheduled_date # The following ActiveRecord chain is granted in existence by validation assertions: (even the first check could be avoided)
    meeting_program ? meeting_program.meeting_session.scheduled_date : '?'
  end

  # Retrieves the Meeting Program short name
  def get_meeting_program_name
    meeting_program ? meeting_program.get_full_name : '?'
  end

  # Retrieves the Meeting Program verbose name
  def get_meeting_program_verbose_name
    meeting_program ? meeting_program.get_verbose_name : '?'
  end
  #-- --------------------------------------------------------------------------
  #++

  # Returns +true+ if this instance is associated to the specified PoolType#code.
  # +false+ otherwise. Code-equality test (w/ safety) checker.
  def has_pool_type_code?(code)
    pool_type ? pool_type.code == code : false
  end

  # Returns +true+ if this instance is associated to the specified EventType#code.
  # +false+ otherwise. Code-equality test (w/ safety) checker.
  def has_event_type_code?(code)
    event_type ? event_type.code == code : false
  end

  # Returns +true+ if this instance is associated to the specified CategoryType#code.
  # +false+ otherwise. Code-equality test (w/ safety) checker.
  def has_category_type_code?(code)
    category_type ? category_type.code == code : false
  end

  # Returns +true+ if this instance is associated to the specified GenderType#code.
  # +false+ otherwise. Code-equality test (w/ safety) checker.
  def has_gender_type_code?(code)
    gender_type ? gender_type.code == code : false
  end

  # Returns +true+ if this instance is associated to the specified GenderType#code.
  # +false+ otherwise. Code-equality test (w/ safety) checker.
  def has_federation_type_code?(code)
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
    get_scheduled_date.year - swimmer.year_of_birth + (get_scheduled_date.month > 9 ? 1 : 0)
  end

end
# rubocop:enable Rails/DynamicFindBy
