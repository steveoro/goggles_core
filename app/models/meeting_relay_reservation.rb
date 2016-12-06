# encoding: utf-8


=begin

= MeetingRelayReservation model

  - version:  6.024
  - author:   Steve A.

=end
class MeetingRelayReservation < ApplicationRecord
  include SwimmerRelatable
  include EventTypeRelatable

  belongs_to :meeting
  belongs_to :user
  belongs_to :team
  belongs_to :swimmer
  belongs_to :badge
  belongs_to :meeting_event

  has_one :season,          through: :meeting
  has_one :season_type,     through: :meeting
  has_one :event_type,      through: :meeting_event
  has_one :meeting_session, through: :meeting_event

  # Other available fields:
  # t.string :notes, limit: 50
  # t.boolean :is_doing_this
  #-- -------------------------------------------------------------------------
  #++
end
