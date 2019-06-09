# frozen_string_literal: true

require 'drop_down_listable'
require 'localizable'

class ExecutionNoteType < ApplicationRecord

  include DropDownListable
  include Localizable

  validates :code, presence: { length: { within: 1..3 }, allow_nil: false }
  validates :code, uniqueness: { message: :already_exists }
  # ----------------------------------------------------------------------------

end
