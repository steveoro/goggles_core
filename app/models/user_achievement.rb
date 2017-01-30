=begin

= UserAchievement model

  - version:  6.069
  - author:   Leega, Steve A.

  Mapper for achievements reached by users.
  This class must be kept free from descriprions and locales.

=end
class UserAchievement < ApplicationRecord
  # XXX [Steve, 20170130] We don't care anymore (so much) about these updates: commented out
#  after_create    UserContentLogger.new('user_achievements')
#  after_update    UserContentLogger.new('user_achievements')
#  before_destroy  UserContentLogger.new('user_achievements')

  belongs_to :user
  belongs_to :achievement

# FIXME for Rails 4+, move required/permitted check to the controller using the model
#  attr_accessible :user_id, :achievement_id

  delegate :name, to: :user, prefix: true
  #-- -------------------------------------------------------------------------
  #++

  # Commodity alias to retrieve the read-only value of the triggering
  # date for this user achievement.
  def date_triggered
    self.created_at
  end
  #-- -------------------------------------------------------------------------
  #++
end
