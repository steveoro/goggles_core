# encoding: utf-8
require 'drop_down_listable'
require 'wrappers/timing'


=begin

= Swimmer model

  - version:  6.00.035
  - author:   Steve A.

=end
class Swimmer < ApplicationRecord
  # [Steve, 20140929] Here we just need to log the updates, since the users
  # can only add or remote UserSwimmerConfirmations, thus updating the only
  # related field on the table (:user_swimmer_confirmations).
  after_update    UserContentLogger.new('swimmers')

  include DropDownListable

  belongs_to :user                                  # [Steve, 20120212] Do not validate associated user!

  # This will be used to discriminate the actual user associated with this data
  # (the "associated_user_id") and the user_id which has created/updated/modified
  # the data itself (usually a user with a higher grant)
  belongs_to :associated_user, class_name: "User",
             foreign_key: "associated_user_id"

  acts_as_taggable_on :tags_by_users
  acts_as_taggable_on :tags_by_teams

  has_many :user_swimmer_confirmations
  has_many :confirmators, through: :user_swimmer_confirmations

  belongs_to            :gender_type
  validates_associated  :gender_type

  has_many :badges
  has_many :teams,          through: :badges
  has_many :category_types, through: :badges
  has_many :seasons,        through: :badges
  has_many :season_types,   through: :badges

  has_many :meeting_individual_results
  has_many :meeting_relay_swimmers
  has_many :meeting_relay_results,  through: :meeting_relay_swimmers

  has_many :meeting_programs,       through: :meeting_individual_results
  has_many :meeting_events,         through: :meeting_programs
  has_many :meeting_sessions,       through: :meeting_individual_results
  has_many :meetings,               through: :meeting_individual_results

  has_many :user_results

  has_many :goggle_cups,            through: :teams
  has_many :goggle_cup_standards

  validates_presence_of :complete_name
  validates_length_of   :complete_name, within: 1..100, allow_nil: false

  validates_length_of   :last_name, maximum: 50
  validates_length_of   :first_name, maximum: 50

  validates_presence_of :year_of_birth
  validates_length_of   :year_of_birth, within: 2..4, allow_nil: false

  validates_length_of :phone_mobile,  maximum:  40
  validates_length_of :phone_number,  maximum:  40
  validates_length_of :e_mail,        maximum: 100
  validates_length_of :nickname,      maximum: 25


  delegate :name, to: :user, prefix: true, allow_nil: true

# FIXME for Rails 4+, move required/permitted check to the controller using the model
#  attr_accessible :associated_user, :user, :user_id,
#                  :gender_type, :gender_type_id, :complete_name, :last_name, :first_name,
#                  :year_of_birth, :phone_mobile, :phone_number, :e_mail,
#                  :nickname, :is_year_guessed

  scope :is_male,             -> { where(["swimmers.gender_type_id = ?", GenderType::MALE_ID]) }
  scope :is_female,           -> { where(["swimmers.gender_type_id = ?", GenderType::FEMALE_ID]) }

  scope :has_results,         -> { where("exists (select 1 from meeting_individual_results where swimmer_id = swimmers.id and not is_disqualified)") }

  scope :sort_by_user,        ->(dir) { order("users.name #{dir.to_s}, swimmers.complete_name #{dir.to_s}") }
  scope :sort_by_name,        ->(dir = 'ASC') { order("complete_name #{dir.to_s}") }
  scope :sort_by_gender_type, ->(dir) { includes(:gender_type).order("gender_types.code #{dir.to_s}, swimmers.complete_name #{dir.to_s}") }
  #-- -------------------------------------------------------------------------
  #++

  # Computes a shorter description for the name associated with this data
  def get_full_name
    last_name.to_s.empty? ? "#{complete_name}" : "#{last_name} #{first_name}"
  end

  # Computes a description for the name associated with this data
  def get_full_name_with_nickname
    last_name.to_s.empty? ? "#{complete_name}#{nickname.to_s.empty? ? '' : ' ('+nickname+')'}" : "#{first_name} #{nickname.to_s.empty? ? '' : ' ('+nickname+') '} #{last_name}"
  end

  # Computes a verbose or formal description for the name associated with this data
  def get_verbose_name
    "#{get_full_name} (#{year_of_birth}, #{gender_type ? gender_type.code : '?'})"
  end

  # Safe getter for the nickname (it can be nil)
  def get_nickname
    self.nickname ? self.nickname : ''
  end
  #-- -------------------------------------------------------------------------
  #++

  # Label symbol corresponding to either a column name or a model method to be used
  # mainly in generating DropDown option lists.
  #
  # @overload inherited from DropDownListable
  #
  def self.get_label_symbol
    :get_full_name
  end
  #-- -------------------------------------------------------------------------
  #++

  # Returns true if the current row's gender_type_id is equal to MALE_ID
  def is_male
    ( self.gender_type_id == GenderType::MALE_ID )
  end

  # Returns true if the current row's gender_type_id is equal to FEMALE_ID
  def is_female
    ( self.gender_type_id == GenderType::FEMALE_ID )
  end
  #-- -------------------------------------------------------------------------
  #++

  # Returns the array of distinct team names associated to the specified swimmer_id.
  # An empty array when not found.
  #
  # This is useful to create multiple links to team-related data, looping on each
  # item.
  #
  def self.get_team_names( swimmer_id )
    swimmer = Swimmer.find_by_id( swimmer_id )
    swimmer ? swimmer.teams.collect{|row| row.name }.uniq : []
  end
  #-- -------------------------------------------------------------------------
  #++

  # Retrieves a comma-separated string containing all the distinct team
  # names associated with this instance.
  #
  def get_team_names
     self.teams ? self.teams.collect{ |row| row.name }.uniq.join(', ') : ''
  end
  #-- -------------------------------------------------------------------------
  #++

  # Returns the Badge row instance for the affiliation to <tt>team_id</tt> for
  # the specified <tt>season_id</tt>.
  # Returns +nil+ when not found.
  #
  def get_badge_for( season_id, team_id )
     self.badges.includes(:season, :team).where( season_id: season_id, team_id: team_id ).first
  end

  # Returns an +Array+ of Badge row instances linked to this Swimmer,
  # possibly filtered by season, if the parameter is given.
  #
  def get_badges_array( season_id = nil )
    # Also possibile with:
    #
    #   Badge.joins( :team, :swimmer ).where(
    #    'badges.season_id' => season_id, swimmer_id: self.id
    #   )
    all_badges = self.badges.includes(:season, :team)
    all_badges = all_badges.where( season_id: season_id ) if season_id
    all_badges
  end

  # Similarly to <tt>self.get_team_names( swimmer_id )</tt>, returns an +Array+
  # where each item is a String composed of the TeamAffiliation's Badge number and
  # the corresponding Team name.
  #
  # This is useful to create multiple links to team-related data, looping on each
  # item.
  # The parameter, when present, allows to filter the results by season.
  #
  def get_badges_with_team_names_array( season_id = nil )
     all_badges = get_badges_array( season_id )
     all_badges.collect{ |row| "#{I18n.t('badge.short')} #{row.number}, #{row.team.editable_name}" }
  end

  # Returns an +Array+ of Badge row instances linked to this Swimmer,
  # filtered by season, having <tt>seasons.header_year = season_header_year</tt>.
  #
  def get_badges_array_for_year( header_year = Season.build_header_year_from_date )
    badges.for_year( header_year ).includes(:season, :team)
  end
  #-- -------------------------------------------------------------------------
  #++

  # Returns true if swimmer has a badge for the given season type and header year.
  # Default values are 'MASFIN' and current year (calendar).
  #
  def has_badge_for_season_and_year?( header_year = Season.build_header_year_from_date, season_type = SeasonType.find_by_code('MASFIN') )
    badges.for_season_type( season_type ).for_year( header_year ).count > 0
  end
  #-- -------------------------------------------------------------------------
  #++

  # Helper getter for the current category type of this swimmer,
  # according to the latest registered badge.
  #
  # It can be nil.
  #
  def get_current_category_type_from_badges
    last_badge = badges.joins(:season).order('seasons.header_year').last
    last_badge.category_type if last_badge
  end


  # Helper getter for the current category type of this swimmer,
  # computed from the two most common season types (MASFIN & MASCSI).
  # Returns an array with the unique category type codes found.
  #
  def get_current_category_type_codes
    last_fin_season = Season.get_last_season_by_type( SeasonType::CODE_MAS_FIN )
    last_csi_season = Season.get_last_season_by_type( SeasonType::CODE_MAS_CSI )
    curr_fin_category = last_fin_season ? CategoryType.get_category_from( last_fin_season.id, self.year_of_birth ) : nil
    curr_csi_category = last_csi_season ? CategoryType.get_category_from( last_csi_season.id, self.year_of_birth ) : nil
    [ curr_fin_category, curr_csi_category ].compact.collect{ |category| category.code }.uniq
  end

  # Get the category type id
  # computed from the two most common season types (MASFIN & MASCSI).
  # Returns an array with the unique category type codes found.
  #
  def get_category_type_for_season( season_id )
    season_id ? CategoryType.get_category_from( season_id, self.year_of_birth ) : nil
  end
  #-- -------------------------------------------------------------------------
  #++

  # Returns the total meters swam by this swimmer
  #
  def get_total_meters_swam
    relay_lengths = self.meeting_relay_swimmers.includes(:event_type).collect{ |mrs| mrs.event_type ? mrs.event_type.phase_length_in_meters : 0 }
    ind_lengths   = self.meeting_individual_results.includes(:event_type).collect{ |mir| mir.event_type ? mir.event_type.length_in_meters : 0 }
    ( relay_lengths + ind_lengths ).inject{ |sum, lenght| sum + lenght }
  end

  # Returns the total time swam by this swimmer as a Timing instance
  #
  def get_total_time_swam
    relay_timings = self.meeting_relay_swimmers.collect{ |mrs| mrs.get_timing_instance.to_hundreds }
    ind_timings   = self.meeting_individual_results.collect{ |mir| mir.get_timing_instance.to_hundreds }
    total_hundreds = ( relay_timings + ind_timings ).inject{ |sum, hundreds| sum + hundreds }
    Timing.new( total_hundreds )
  end
  #-- -------------------------------------------------------------------------
  #++

  # Returns the first meeting registered for this Swimmer; nil when not found.
  def get_first_meeting
    ms = self.meeting_sessions.includes(:meeting).order(:scheduled_date).first
    ms ? ms.meeting : nil
  end

  # Returns the last meeting registered for this Swimmer; nil when not found.
  def get_last_meeting
    ms = self.meeting_sessions.includes(:meeting).order(:scheduled_date).last
    ms ? ms.meeting : nil
  end
  #-- -------------------------------------------------------------------------
  #++

  # Returns the best-ever MeetingIndividualResult according to the not-null standard points registered.
  # +nil+ when not found.
  #
  def get_best_individual_result( score_method_sym = :standard_points )
    meeting_individual_results.is_valid.has_points( score_method_sym ).order( score_method_sym ).last
  end

  # Returns the worst-ever MeetingIndividualResult according to the not-null standard points registered.
  # +nil+ when not found.
  #
  def get_worst_individual_result( score_method_sym = :standard_points )
    meeting_individual_results.is_valid.has_points( score_method_sym ).order( score_method_sym ).first
  end

  # Returns the total count of registered disqualifications
  def get_disqualifications_count
    ( self.meeting_individual_results.where(is_disqualified: true).count +
      self.meeting_relay_results.where(is_disqualified: true).count )
  end
  #-- -------------------------------------------------------------------------
  #++
end
