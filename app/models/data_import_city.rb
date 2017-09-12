#require 'data_importable'


class DataImportCity < ApplicationRecord
  include DataImportable

  belongs_to :user                                  # [Steve, 20120212] Do not validate associated user!

  belongs_to :city, foreign_key: "conflicting_id"

  validates_presence_of :import_text

  validates_presence_of   :name, length: { within: 1..50 }, allow_nil: false
  validates_uniqueness_of :name, scope: :zip, message: :already_exists
  validates_length_of     :zip,  maximum: 6
  validates_presence_of   :area, length: { within: 1..50 }, allow_nil: false
  validates_presence_of   :country, length: { within: 1..50 }, allow_nil: false
  validates_presence_of   :country_code, length: { within: 1..10 }, allow_nil: false

#  attr_accessible :data_import_session_id, :import_text, :conflicting_id,
#                  :user, :user_id,
#                  :name, :zip, :area, :country, :country_code
  # ----------------------------------------------------------------------------

end
