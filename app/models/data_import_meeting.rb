# frozen_string_literal: true

# require 'data_importable'

class DataImportMeeting < ApplicationRecord

  include DataImportable

  belongs_to :user # [Steve, 20120212] Do not validate associated user!

  belongs_to :meeting, foreign_key: 'conflicting_id'

  validates :import_text, presence: true

  belongs_to :season
  belongs_to :data_import_season
  belongs_to :edition_type
  belongs_to :timing_type
  validates_associated :season
  validates_associated :edition_type
  validates_associated :timing_type

  belongs_to(:individual_score_computation_type,
             class_name: 'ScoreComputationType',
             foreign_key: 'individual_score_computation_type_id')
  belongs_to(:relay_score_computation_type,
             class_name: 'ScoreComputationType',
             foreign_key: 'relay_score_computation_type_id')
  belongs_to(:team_score_computation_type,
             class_name: 'ScoreComputationType',
             foreign_key: 'team_score_computation_type_id')
  belongs_to(:meeting_score_computation_type,
             class_name: 'ScoreComputationType',
             foreign_key: 'meeting_score_computation_type_id')

  has_one  :season_type, through: :season

  has_many :meeting_sessions
  has_many :data_import_meeting_sessions

  has_many :meeting_programs, through: :meeting_sessions
  has_many :data_import_meeting_programs, through: :data_import_meeting_sessions

  has_many :meeting_individual_results, through: :meeting_programs
  has_many :data_import_meeting_individual_results, through: :data_import_meeting_programs

  has_many :meeting_relay_results, through: :meeting_programs
  has_many :data_import_meeting_relay_results, through: :data_import_meeting_programs

  validates :code, presence: true
  validates :code, length: { within: 1..50, allow_nil: false }

  validates :description, presence: true
  validates :description, length: { maximum: 100 }

  validates :reference_phone, length: { maximum: 40 }
  validates :reference_e_mail, length: { maximum: 50 }
  validates :reference_name, length: { maximum: 50 }

  validates :header_year, length: { maximum: 9, allow_nil: false }
  validates :configuration_file, length: { maximum: 255 }

  validates :max_individual_events, length: { maximum: 1 }
  validates :max_individual_events_per_session, length: { maximum: 1 }
  validates :edition, length: { maximum: 3, allow_nil: false }

  #  attr_accessible :data_import_session_id, :import_text, :conflicting_id,
  #                  :user, :user_id,
  #                  :description, :entry_deadline, :has_warm_up_pool, :is_under_25_admitted,
  #                  :reference_phone, :reference_e_mail, :reference_name, :notes, :has_invitation,
  #                  :has_start_list, :are_results_acquired, :max_individual_events, :configuration_file,
  #                  :edition,
  #                  :data_import_season_id, :season_id,
  #                  :header_date, :code, :header_year,
  #                  :max_individual_events_per_session, :is_out_of_season,
  #                  :edition_type_id, :timing_type_id, :individual_score_computation_type_id,
  #                  :relay_score_computation_type_id, :team_score_computation_type_id,
  #                  :meeting_score_computation_type_id

  scope :sort_by_user,    ->(dir) { order("users.name #{dir}, data_import_meetings.description #{dir}") }
  scope :sort_by_season,  ->(dir) { order("seasons.begin_date #{dir}, data_import_meetings.description #{dir}") }

  # ----------------------------------------------------------------------------
  # Base methods:
  # ----------------------------------------------------------------------------

  # Computes the shortest possible description for the name associated with this data
  def get_short_name
    sname = description.split(/trofeo|meeting/i)
    if sname.length > 1
      # Remove spaces, split in tokens, delete empty tokens and take just the first 3, joined together:
      (sname[1].strip.split(/\s|\,/).delete_if { |item| item == '' })[0..2].join(' ')
    else
      # Just use the name if it wasn't "splittable":
      sname[0]
    end
  end

  # Computes a shorter description for the name associated with this data
  def get_full_name
    description
  end

  # Computes a verbose or formal description for the name associated with this data
  def get_verbose_name
    "#{description} (#{get_season_type})"
  end

  # Retrieves the user name associated with this instance
  def user_name
    user ? user.name : ''
  end
  # ----------------------------------------------------------------------------

  # Retrieves the Season Type short name, either from season or from data_import_season
  def get_season_type
    season ? season.get_season_type : (data_import_season ? data_import_season.get_season_type : '?')
  end
  # ----------------------------------------------------------------------------

end
