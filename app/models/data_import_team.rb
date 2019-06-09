# frozen_string_literal: true

# require 'data_importable'

class DataImportTeam < ApplicationRecord

  include DataImportable

  belongs_to :user                                  # [Steve, 20120212] Do not validate associated user!

  belongs_to :team, foreign_key: 'conflicting_id'

  validates :import_text, presence: true

  belongs_to :data_import_city
  belongs_to :city                                  # City can be null especially in Teams added by data-import

  validates :name, presence: { length: { within: 1..60 }, allow_nil: false }

  # XXX [Steve, 20130925] :badge_number can be used as a temporary storage
  # for a team_affiliations.number found during data-import parsing,
  # skipping the need for a dedicated team_affiliations temp. table:
  validates :badge_number, length: { maximum: 40 }

  scope :sort_by_conflicting_rows_id,  ->(dir) { order("conflicting_id #{dir}") }
  scope :sort_by_user,                 ->(dir) { order("users.name #{dir}, data_import_teams.name #{dir}") }
  scope :sort_by_city,                 ->(dir) { order("cities.name #{dir}, data_import_teams.name #{dir}") }

  delegate :name, to: :user, prefix: true

  #  attr_accessible :data_import_session_id, :conflicting_id, :import_text,
  #                  :name, :badge_number, :data_import_city_id, :city_id, :user_id
  #-- -------------------------------------------------------------------------
  #++

  # Computes a shorter description for the name associated with this data
  def get_full_name
    name
  end

  # Computes a verbose or formal description for the name associated with this data
  def get_verbose_name
    "#{name}#{(city ? ', ' + city.get_full_name : (data_import_city ? ', ' + data_import_city.get_full_name : ''))}"
  end

  # Retrieves the user name associated with this instance
  def user_name
    user ? user.name : ''
  end
  # ----------------------------------------------------------------------------

end
