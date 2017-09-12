class DataImportSession < ApplicationRecord
  has_many :data_import_swimmers
  has_many :data_import_teams
  has_many :data_import_badges
  has_many :data_import_cities
  has_many :data_import_seasons
  has_many :data_import_meetings
  has_many :data_import_meeting_sessions
  has_many :data_import_meeting_programs
  has_many :data_import_meeting_individual_results

  has_many :data_import_team_analysis_results
  has_many :data_import_swimmer_analysis_results

  belongs_to :data_import_season
  belongs_to :season
  validates_associated :season

  belongs_to :admin, foreign_key: 'user_id'

#  attr_accessible :phase, :file_format, :file_name, :source_data, :admin,
#                  :total_data_rows, :season_id, :phase_1_log, :phase_2_log, :phase_3_log,
#                  :sql_diff, :user_id
end
