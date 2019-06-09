# frozen_string_literal: true

require 'localizable'

class Achievement < ApplicationRecord

  include Localizable

  belongs_to :user

  has_many :achievement_rows

  validates :code, presence: { length: { within: 1..10 }, allow_nil: false }
  validates :code, uniqueness: { message: :already_exists }
  # ----------------------------------------------------------------------------

end
