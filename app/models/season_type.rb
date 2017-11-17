require 'drop_down_listable'


class SeasonType < ApplicationRecord
  include DropDownListable

  # Commodity reference to a specific code stored in the DB; make sure this value is always correct
  CODE_MAS_FIN = 'MASFIN'

  # Commodity reference to a specific code stored in the DB; make sure this value is always correct
  CODE_MAS_CSI = 'MASCSI'

  validates_presence_of   :code, length: { within: 1..10 }, allow_nil: false
  validates_uniqueness_of :code, message: :already_exists

  validates_length_of     :description, maximum: 100
  validates_length_of     :short_name, maximum: 40

  belongs_to :federation_type
  validates_presence_of :federation_type            # (must be not null)
  validates_associated :federation_type             # (foreign key integrity)

  has_many :seasons
  has_many :swimmers,     through: :seasons
  has_many :teams,        through: :seasons
  has_many :event_types,  through: :seasons  # FIXME This one doesn't work

  scope :is_master,   -> { where("code like 'MAS%'") }
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
  def self.get_id_by_code( code )
    season_type = SeasonType.find_by_code( code )
    season_type ? season_type.id : 0
  end
  # ----------------------------------------------------------------------------
end
