# frozen_string_literal: true

require 'drop_down_listable'

class SeasonType < ApplicationRecord

  include DropDownListable

  # Commodity reference to a specific code stored in the DB; make sure this value is always correct
  CODE_MAS_FIN = 'MASFIN'

  # Commodity reference to a specific code stored in the DB; make sure this value is always correct
  CODE_MAS_CSI = 'MASCSI'

  validates :code, presence: { length: { within: 1..10 }, allow_nil: false }
  validates :code, uniqueness: { message: :already_exists }

  validates     :description, length: { maximum: 100 }
  validates     :short_name, length: { maximum: 40 }

  belongs_to :federation_type
  validates :federation_type, presence: true # (must be not null)
  validates_associated :federation_type # (foreign key integrity)

  has_many :seasons
  has_many :swimmers,     through: :seasons
  has_many :teams,        through: :seasons
  has_many :event_types,  through: :seasons # FIXME: This one doesn't work

  scope :is_master, -> { where("code like 'MAS%'") }
  # ----------------------------------------------------------------------------

  # Comodity helper
  def get_full_name
    short_name
  end

  # Label symbol corresponding to either a column name or a model method to be used
  # mainly in generating DropDown option lists.
  #
  # @overload inherited from DropDownListable
  #
  def self.get_label_symbol
    :short_name
  end
  # ----------------------------------------------------------------------------

  # ID getter for the specified code; returns 0 on error
  #
  def self.get_id_by_code(code)
    season_type = SeasonType.find_by(code: code)
    season_type ? season_type.id : 0
  end
  # ----------------------------------------------------------------------------

end
