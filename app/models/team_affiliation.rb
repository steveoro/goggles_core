
=begin

= TeamAffiliation model

 This entity stores the *team* affiliation to a specific sporting season..

=end
class TeamAffiliation < ActiveRecord::Base

  belongs_to :user
  # [Steve, 20120212] Validating on User fails always because of validation requirements inside User (password & salt)
#  validates_associated :user                       # (Do not enable this for User)

  belongs_to :team
  belongs_to :season
  validates_associated :team
  validates_associated :season

  validates_presence_of :name
  validates_length_of   :name, within: 1..100, allow_nil: false

  validates_length_of   :number, maximum: 20

  has_one  :season_type, through: :season

  has_many :badges
  has_many :meeting_individual_results
  has_many :team_managers

  scope :sort_team_affiliation_by_user,    ->(dir) { order("users.name #{dir.to_s}") }
  scope :sort_team_affiliation_by_team,    ->(dir) { order("teams.name #{dir.to_s}") }
  scope :sort_team_affiliation_by_season,  ->(dir) { order("seasons.begin_date #{dir.to_s}, team_affiliations.name #{dir.to_s}") }


  delegate :name, to: :user, prefix: true
  delegate :name, :editable_name, to: :team, prefix: true

  attr_accessible :name, :number, :team_id, :season_id,
                  :user_id, :is_autofilled, :must_calculate_goggle_cup

  scope :for_season_type,       ->(season_type)    { joins(:season_type).where(['season_types.id = ?', season_type.id]) }
  scope :for_year,              ->(header_year)    { joins(:season).where( ['seasons.header_year = ?', header_year]) }
  #-- -------------------------------------------------------------------------
  #++

  # Computes a shorter description for the name associated with this data
  def get_full_name
    name
  end

  # Computes a verbose or formal description for the name associated with this data
  def get_verbose_name
    "(#{number}) #{name}"
  end
  #-- -------------------------------------------------------------------------
  #++
end
