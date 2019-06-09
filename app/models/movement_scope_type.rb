# frozen_string_literal: true

require 'drop_down_listable'
require 'localizable'

class MovementScopeType < ApplicationRecord

  include DropDownListable
  include Localizable

  # Commodity reference to a specific code stored in the DB; make sure this value is always correct
  CODE_GENERIC = 'N' # If it's full or generic we may want to discriminate. (This code allows to avoid printing generic-type movement scopes in some methods.)

  validates :code, presence: { length: { maximum: 1 }, allow_nil: false }
  validates :code, uniqueness: { message: :already_exists }
  # ----------------------------------------------------------------------------

end
