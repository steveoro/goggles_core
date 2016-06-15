require 'localizable'


class Achievement < ActiveRecord::Base
  include Localizable

  belongs_to :user

  has_many :achievement_rows

  validates_presence_of   :code, length: { within: 1..10 }, allow_nil: false
  validates_uniqueness_of :code, message: :already_exists
  # ----------------------------------------------------------------------------
end
