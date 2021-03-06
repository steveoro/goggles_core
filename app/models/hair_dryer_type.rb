# frozen_string_literal: true

require 'drop_down_listable'
require 'localizable'

class HairDryerType < ApplicationRecord

  include DropDownListable
  include Localizable

  validates :code, presence: { length: { within: 1..3 }, allow_nil: false }
  validates :code, uniqueness: { message: :already_exists }

  # Unique IDs used inside the DB, the description will be retrieved using I18n.t()
  NONE_ID         = 0
  FREE_ID         = 1
  PAY_CURRENCY_ID = 2
  PAY_TOKENS_ID   = 3
  # ----------------------------------------------------------------------------

  # Commodity Array used to enlist all defined IDs
  #
  TYPES_HASH = {
    NONE_ID => 'no',
    FREE_ID => 'ok',
    PAY_CURRENCY_ID => 'pc',
    PAY_TOKENS_ID => 'pt'
  }.freeze
  # ----------------------------------------------------------------------------

end
