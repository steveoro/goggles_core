# == ComputedSeasonRanking
#
# This entity stores the *team* final ranking in a (closed) season
# Should provide data for season history (hall of fame), palmares and so on
# without runtime ranking computation
#
# N.B. Maybe in a future should be updatated runtime for current seasons too
#
class ComputedSeasonRanking < ApplicationRecord

  belongs_to :team
  belongs_to :season
  validates_associated :team
  validates_associated :season

  validates_presence_of     :rank
  validates_presence_of     :total_points
  validates_numericality_of :rank
  validates_numericality_of :total_points

  scope :for_team,         ->(team)   { where(team_id: team.id) }
  scope :for_season,       ->(season) { where(season_id: season.id) }
  scope :sort_by_rank,     ->(dir = 'ASC') { order("rank #{dir.to_s}") }

  delegate :name,        to: :team,   prefix: true
  delegate :description, to: :season, prefix: true

# FIXME for Rails 4+, move required/permitted check to the controller using the model
#  attr_accessible :season_id, :team_id, :rank, :total_points

  # ----------------------------------------------------------------------------
  # Base methods:
  # ----------------------------------------------------------------------------
  #++

  # Computes a shorter description for the name associated with this data
  def get_full_name
    "#{season_description} - #{team_name}: #{rank}"
  end

  # Computes a verbose or formal description for the name associated with this data
  def get_verbose_name
    "#{season_description} - #{team_name}: #{rank}, #{total_points.to_s}"
  end
  # ----------------------------------------------------------------------------
end
