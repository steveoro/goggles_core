#require 'data_importable'


class DataImportSwimmer < ApplicationRecord
  include DataImportable

  belongs_to :user                                  # [Steve, 20120212] Do not validate associated user!

  belongs_to :swimmer, foreign_key: "conflicting_id"
  belongs_to :gender_type

  validates_presence_of :import_text

  validates_presence_of :complete_name
  validates_length_of   :complete_name, within: 1..100, allow_nil: false

  validates_length_of   :last_name, maximum: 50
  validates_length_of   :first_name, maximum: 50

  validates_presence_of :year_of_birth
  validates_length_of   :year_of_birth, within: 2..4, allow_nil: false

#  attr_accessible :data_import_session_id, :import_text, :conflicting_id,
#                  :user, :user_id,
#                  :gender_type, :gender_type_id, :complete_name, :last_name, :first_name,
#                  :year_of_birth

  scope :sort_by_conflicting_rows_id,  ->(dir) { order("conflicting_id #{dir.to_s}") }
  scope :sort_by_user,                 ->(dir) { order("users.name #{dir.to_s}, data_import_swimmers.name #{dir.to_s}") }
  scope :sort_by_gender_type,          ->(dir) { order("gender_types.code #{dir.to_s}, data_import_swimmers.name #{dir.to_s}") }


  # ----------------------------------------------------------------------------
  # Base methods:
  # ----------------------------------------------------------------------------


  # Computes a shorter description for the name associated with this data
  def get_full_name
    last_name ? "#{last_name} #{first_name}" : "#{complete_name}"
  end

  # Computes a verbose or formal description for the name associated with this data
  def get_verbose_name
    "#{get_full_name} (#{year_of_birth}, #{gender_type ? gender_type.code : '?'})"
  end

  # Retrieves the user name associated with this instance
  def user_name
    self.user ? self.user.name : ''
  end
  # ---------------------------------------------------------------------------

end
