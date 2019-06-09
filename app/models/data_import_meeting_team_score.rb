# frozen_string_literal: true

# require 'data_importable'

class DataImportMeetingTeamScore < ApplicationRecord

  include DataImportable

  belongs_to :user # [Steve, 20120212] Do not validate associated user!

  belongs_to :meeting_team_score, foreign_key: 'conflicting_id', optional: true

  belongs_to :data_import_team, optional: true
  belongs_to :team, optional: true
  belongs_to :team_affiliation, optional: true
  belongs_to :data_import_meeting, optional: true
  belongs_to :meeting, optional: true

  belongs_to :season
  validates_associated :season

  validates :rank, presence: true
  validates :sum_individual_points, presence: true
  validates :sum_relay_points, presence: true
  validates :sum_team_points, presence: true
  validates :meeting_individual_points, presence: true
  validates :meeting_relay_points, presence: true
  validates :meeting_team_points, presence: true
  validates :season_individual_points, presence: true
  validates :season_relay_points, presence: true
  validates :season_team_points, presence: true
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

  #  attr_accessible :data_import_session_id, :import_text, :conflicting_id,
  #                  :user, :user_id,
  #                  :sum_individual_points, :sum_relay_points, :sum_team_points,
  #                  :data_import_team_id, :data_import_meeting_id,
  #                  :team_id, :meeting_id, :season_id, :team_affiliation_id,
  #                  :rank,
  #                  :meeting_individual_points, :meeting_relay_points, :meeting_team_points,
  #                  :season_individual_points, :season_relay_points, :season_team_points,

  # ----------------------------------------------------------------------------
  # Base methods:
  # ----------------------------------------------------------------------------

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
    team ? team.get_full_name : (data_import_team ? data_import_team.get_full_name : '?')
  end

  # Retrieves the Meeting name
  def get_meeting_name
    meeting ? meeting.get_full_name : (data_import_meeting ? data_import_meeting.get_full_name : '?')
  end
  # ----------------------------------------------------------------------------

end
