# encoding: utf-8


=begin

= IndividualRecord model

  - version:  4.00.359.20140718
  - author:   Steve A.

  Stores the current & best individual results (or records) collected from all
  team or federation results.

  This entity must be periodically updated by a batch rake task (usually after
  each MeetingIndividualResult insertion).

=end
class IndividualRecord < ApplicationRecord
  include SwimmerRelatable
  include TimingGettable
  include TimingValidatable

  belongs_to :pool_type
  belongs_to :event_type
  belongs_to :category_type
  belongs_to :gender_type
  belongs_to :record_type

  belongs_to :team
  belongs_to :season
  has_one :season_type, through: :season
  belongs_to :federation_type                       # [Steve, 20140718] Redundant shortcut to season.season_type.federation_type. Not really used anymore

  belongs_to :meeting_individual_result             # (May be null)

  validates_associated :pool_type
  validates_associated :event_type
  validates_associated :category_type
  validates_associated :gender_type
  validates_associated :record_type

  validates_associated :team
  validates_associated :season
  validates_associated :federation_type

  # WARNING: use the dedicated scopes below to filter out specific season_types or teams Ids (#for_team & #for_season_type) and combine them with caution!
  # Scopes all the results that are computed for a specific Team
  scope :team_records,          -> { joins(:record_type).where( 'record_types.is_for_teams' => true ) }
  # Scopes all the results that are computed for a specific Season
  scope :seasonal_records,      -> { joins(:record_type).where( 'record_types.is_for_seasons' => true ) }
  # Scopes all the results that are classified as Federation-related or 'generic records' (code: 'FOR').
  scope :generic_type_records,  -> { joins(:record_type).where( 'record_types.code' => 'FOR' ) }

  # Selects all the results that are computed for a specific Team#id:
  scope :for_team,              ->(id)   { team_records.where( team_id: id ) }

  # Selects all the results that are computed for a specific SeasonType or FederationType:
  scope :for_season_type,       ->(id)   { generic_type_records.includes(:season_type).joins(:season_type).where( 'season_types.id' => id ) }
  scope :for_federation,        ->(id)   { generic_type_records.where( federation_type_id: id ) }
  scope :for_federation_code,   ->(code) { generic_type_records.includes(:federation_type).joins(:federation_type).where( 'federation_types.code' => code ) }

  scope :for_record_type,       ->(code) { joins(:record_type).where( 'record_types.code' => code ) }
  #-- -------------------------------------------------------------------------
  #++

  # Fills the current instance with values from the specified MeetingIndividualResult,
  # returning self.
  #
  def from_individual_result( individual_result, record_type )
    raise ArgumentError.new("The result specified is not a valid instance of MeetingIndividualResult!") unless individual_result.instance_of?( MeetingIndividualResult )
    raise ArgumentError.new("The record type specified is not a valid instance of RecordType!") unless record_type.instance_of?( RecordType )
    self.meeting_individual_result_id = individual_result.id
    self.pool_type_id        = individual_result.pool_type.id
    self.event_type_id       = individual_result.event_type.id
    self.category_type_id    = individual_result.category_type.id
    self.gender_type_id      = individual_result.gender_type.id
    self.minutes             = individual_result.minutes
    self.seconds             = individual_result.seconds
    self.hundreds            = individual_result.hundreds
    self.swimmer_id          = individual_result.swimmer_id
    self.team_id             = individual_result.team_id
    self.season_id           = individual_result.season.id
    self.federation_type_id  = individual_result.season.federation_type.id
    self.record_type_id      = record_type.id
    self.is_team_record      = record_type.is_for_teams
    self
  end
  #-- -------------------------------------------------------------------------
  #++
end
#-- ---------------------------------------------------------------------------
#++
