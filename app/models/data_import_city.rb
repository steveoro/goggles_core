# frozen_string_literal: true

# require 'data_importable'

class DataImportCity < ApplicationRecord

  include DataImportable

  belongs_to :user # [Steve, 20120212] Do not validate associated user!

  belongs_to :city, foreign_key: 'conflicting_id'

  validates :import_text, presence: true

  validates :name, presence: { length: { within: 1..50 }, allow_nil: false }
  validates :name, uniqueness: { scope: :zip, message: :already_exists }
  validates :zip, length: { maximum: 6 }
  validates   :area, presence: { length: { within: 1..50 }, allow_nil: false }
  validates   :country, presence: { length: { within: 1..50 }, allow_nil: false }
  validates   :country_code, presence: { length: { within: 1..10 }, allow_nil: false }

  #  attr_accessible :data_import_session_id, :import_text, :conflicting_id,
  #                  :user, :user_id,
  #                  :name, :zip, :area, :country, :country_code
  # ----------------------------------------------------------------------------

end
