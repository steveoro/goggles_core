=begin

= Badge payment

  - version:  6.374
  - author:   Leega

=end
class BadgePayment < ApplicationRecord
  belongs_to :user                                  # [Steve, 20120212] Do not validate associated user!
  belongs_to :badge

  validates_associated :badge

  validates_presence_of :payment_date, allow_nil: false
  validates_presence_of :amount, allow_nil: false

  has_one  :swimmer, through: :badge
  has_one  :season,  through: :badge
  has_one  :team,    through: :badge

  scope :sort_by_user,  ->(dir)      { joins(:user).order("users.name #{dir.to_s}, badge_payments.created_at #{dir.to_s}") }
  scope :sort_by_date,  ->(dir)      { order("badge_payments.payment_date #{dir.to_s}") }

  scope :for_badge,     ->(badge)    { where( badge_id: badge.id ) }
  scope :for_badges,    ->(badges)   { where( badge_id: badges.ids ) }
  scope :for_swimmer,   ->(swimmer)  { joins(:swimmer).where( "swimmers.id = #{swimmer.id}" ) }
  scope :for_team,      ->(team)     { joins(:team).where( "team.id = #{team.id}" ) }

  delegate :name, to: :user, prefix: true
  delegate :complete_name, to: :swimmer, prefix: true
  #-- -------------------------------------------------------------------------
  #++

  # Returns a short description or title for the current instance
  def get_full_name
    self.swimmer_complete_name + ' il ' + self.payment_date.to_s + ': ' + self.amount.to_s
  end
  #-- -------------------------------------------------------------------------
  #++
end
