# encoding: utf-8


=begin

= MeetingRelayReservation model

  - version:  6.053
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
  has_one :category_type,   through: :badge
  has_one :gender_type,     through: :swimmer

  # Other available fields:
  # t.string :notes, limit: 50
  # t.boolean :is_doing_this
  #-- -------------------------------------------------------------------------
  #++


  # Retrieves the (first) MeetingProgram associated with this instance, whenever possible.
  # Returns nil otherwise.
  #
  def meeting_program
    MeetingProgram.where(
      meeting_event_id: meeting_event.id,
      category_type_id: category_type.id,
      gender_type_id:   gender_type.id
    ).first
  end
  #-- -------------------------------------------------------------------------
  #++
end
