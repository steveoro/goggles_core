# frozen_string_literal: true

#
# = TeamAffiliation model
#
#  This entity stores the *team* affiliation to a specific sporting season..
#
class TeamAffiliation < ApplicationRecord

  belongs_to :user
  # [Steve, 20120212] Validating on User fails always because of validation requirements inside User (password & salt)
  #  validates_associated :user                       # (Do not enable this for User)

  belongs_to :team
  belongs_to :season
  validates_associated :team
  validates_associated :season

  validates :name, presence: true
  validates :name, length: { within: 1..100, allow_nil: false }

  validates   :number, length: { maximum: 20 }

  has_one  :season_type, through: :season

  has_many :badges
  has_many :meeting_individual_results
  has_many :team_managers

  scope :sort_team_affiliation_by_user,    ->(dir) { joins(:user).order("users.name #{dir}") }
  scope :sort_team_affiliation_by_team,    ->(dir) { joins(:team).order("teams.name #{dir}") }
  scope :sort_team_affiliation_by_season,  ->(dir) { joins(:season).order("seasons.begin_date #{dir}, team_affiliations.name #{dir}") }

  delegate :name, to: :user, prefix: true
  delegate :name, :editable_name, to: :team, prefix: true

  # FIXME: for Rails 4+, move required/permitted check to the controller using the model
  #  attr_accessible :name, :number, :team_id, :season_id,
  #                  :user_id, :is_autofilled, :must_calculate_goggle_cup

  scope :for_season_type,       ->(season_type)    { joins(:season_type).where(['season_types.id = ?', season_type.id]) }
  scope :for_year,              ->(header_year)    { joins(:season).where(['seasons.header_year = ?', header_year]) }
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
