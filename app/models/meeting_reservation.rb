# encoding: utf-8


=begin

= MeetingReservation model

  - version:  6.018
  - author:   Steve A.

=end
class MeetingReservation < ApplicationRecord
  include SwimmerRelatable

  belongs_to :meeting
  belongs_to :user
  belongs_to :team
  belongs_to :swimmer
  belongs_to :badge

  has_one  :season,           through: :meeting
  has_one  :season_type,      through: :meeting
  has_many :meeting_sessions, through: :meeting
end
