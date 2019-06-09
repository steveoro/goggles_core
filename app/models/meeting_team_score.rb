# frozen_string_literal: true

# == MeetingTeamScore
#
# This entity stores the *team* scoring per meeting and is used
# to prepare the final meeting result chart of all the registered teams
# for a specific meeting.
#
class MeetingTeamScore < ApplicationRecord

  belongs_to :user
  # [Steve, 20120212] Validating on User fails always because of validation requirements inside User (password & salt)
  #  validates_associated :user                       # (Do not enable this for User)

  belongs_to :team # Since meetings are already "filtered" by season, here we link directly to teams, instead of team_affiliations
  belongs_to :team_affiliation
  belongs_to :meeting
  belongs_to :season
  validates_associated :team
  validates_associated :team_affiliation
  validates_associated :meeting
  validates_associated :season

  validates     :rank, presence: true
  validates     :sum_individual_points, presence: true
  validates     :sum_relay_points, presence: true
  validates     :sum_team_points, presence: true
  validates     :meeting_individual_points, presence: true
  validates     :meeting_relay_points, presence: true
  validates     :meeting_team_points, presence: true
  validates     :season_individual_points, presence: true
  validates     :season_relay_points, presence: true
  validates     :season_team_points, presence: true
  validates :rank, numericality: true
  validates :sum_individual_points, numericality: true
  validates :sum_relay_points, numericality: true
  validates :sum_team_points, numericality: true
  validates :meeting_individual_points, numericality: true
  validates :meeting_relay_points, numericality: true
  validates :meeting_team_points, numericality: true
  validates :season_individual_points, numericality: true
  validates :season_relay_points, numericality: true
  validates :season_team_points, numericality: true

  # FIXME: for Rails 4+, move required/permitted check to the controller using the model
  #  attr_accessible :rank, :sum_individual_points, :sum_relay_points, :sum_team_points,
  #                  :meeting_individual_points, :meeting_relay_points, :meeting_team_points,
  #                  :season_individual_points, :season_relay_points, :season_team_points,
  #                  :team, :team_affiliation, :meeting, :season,
  #                  :team_id, :team_affiliation_id, :meeting_id, :season_id, :user_id

  scope :has_season_points, -> { where('(season_individual_points + season_relay_points + season_team_points) > 0') }
  scope :for_team,          ->(team)    { where(team_id: team.id) }
  scope :for_meeting,       ->(meeting) { where(meeting_id: meeting.id) }

  # ----------------------------------------------------------------------------
  # Base methods:
  # ----------------------------------------------------------------------------
  #++

  # Computes a shorter description for the name associated with this data
  def get_full_name
    "#{get_team_name}: #{total_individual_points} + #{total_relay_points}"
  end

  # Computes a verbose or formal description for the name associated with this data
  def get_verbose_name
    "#{get_meeting_name}: #{get_team_name} = #{total_individual_points} + #{total_relay_points}"
  end

  # Retrieves the user name associated with this instance
  def user_name
    user ? user.name : ''
  end
  # ----------------------------------------------------------------------------

  # Retrieves the team name
  def get_team_name
    team ? team.get_full_name : '?'
  end

  # Retrieves the Meeting name
  def get_meeting_name
    meeting ? meeting.get_full_name : '?'
  end
  # ----------------------------------------------------------------------------

end
