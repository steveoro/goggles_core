# frozen_string_literal: true

# require 'data_importable'

class DataImportBadge < ApplicationRecord

  include DataImportable

  belongs_to :user # [Steve, 20120212] Do not validate associated user!

  belongs_to :badge, foreign_key: 'conflicting_id'

  validates :import_text, presence: true

  belongs_to :data_import_season
  belongs_to :data_import_swimmer
  belongs_to :data_import_team
  belongs_to :season
  belongs_to :swimmer
  belongs_to :team
  belongs_to :team_affiliation

  belongs_to :category_type
  belongs_to :entry_time_type

  validates_associated :category_type
  validates_associated :entry_time_type

  validates :number, presence: { length: { maximum: 40 }, allow_nil: true }

  #  attr_accessible :data_import_session_id, :import_text, :conflicting_id,
  #                  :user, :user_id,
  #                  :data_import_swimmer_id, :data_import_team_id, :data_import_season_id,
  #                  :number,
  #                  :swimmer_id, :team_id, :season_id, :category_type_id,
  #                  :entry_time_type_id, :team_affiliation_id

  scope :sort_by_conflicting_rows_id,     ->(dir) { order("conflicting_id #{dir}") }
  scope :sort_by_user,                    ->(dir) { order("users.name #{dir}, data_import_badges.number #{dir}") }
  scope :sort_by_season,                  ->(dir) { order("seasons.begin_date #{dir}, data_import_badges.number #{dir}") }
  scope :sort_by_team,                    ->(dir) { order("teams.name #{dir}, data_import_badges.number #{dir}") }
  scope :sort_by_swimmer,                 ->(dir) { order("swimmers.last_name #{dir}, swimmers.first_name #{dir}") }
  scope :sort_by_category_type,           ->(dir) { order("category_types.code #{dir}, data_import_badges.number #{dir}") }
  # ----------------------------------------------------------------------------

end
