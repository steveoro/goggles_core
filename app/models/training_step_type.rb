# frozen_string_literal: true

require 'drop_down_listable'
require 'localizable'

class TrainingStepType < ApplicationRecord

  include DropDownListable
  include Localizable

  validates :step_order, presence: { length: { within: 1..3 }, allow_nil: false }
  validates :step_order, numericality: true
  validates :code, presence: { length: { maximum: 1 }, allow_nil: false }
  validates :code, uniqueness: { message: :already_exists }

  scope :sort_by_step_order, -> { order('step_order') }
  # ----------------------------------------------------------------------------

  # [Steve, 20140127] Update: since we want to force ordering according to the step order,
  # we'll use the dedicated scope method sort_by_step_order instead of the more standardized
  # array sorting by label method: [].sort_by{ |ar| ar[0] }

end
