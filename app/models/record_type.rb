# frozen_string_literal: true

require 'drop_down_listable'
require 'localizable'

class RecordType < ApplicationRecord

  include DropDownListable
  include Localizable

  validates :code, presence: { length: { maximum: 3 }, allow_nil: false }
  validates :code, uniqueness: { message: :already_exists }

  # Filtering by record type scopes
  scope :for_swimmers,        -> { where(is_for_swimmers: true) }
  scope :for_teams,           -> { where(is_for_teams: true) }
  scope :for_seasons,         -> { where(is_for_seasons: true) }
  # ----------------------------------------------------------------------------

  # Returns default record types for unhadled record types request
  # in record scanning
  # Probably not necessary. In any case, deprecate.
  #
  def self.default_record_type_id
    7
  end

end
