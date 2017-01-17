# encoding: utf-8
require 'wrappers/timing'


=begin

= MeetingEventReservation model

  - version:  6.053
  - author:   Steve A.

=end
class MeetingEventReservation < ApplicationRecord
  include SwimmerRelatable
  include EventTypeRelatable

  belongs_to :meeting
  belongs_to :team
  belongs_to :swimmer
  belongs_to :badge
  belongs_to :meeting_event
  belongs_to :user

  has_one :season,          through: :meeting
  has_one :season_type,     through: :meeting
  has_one :event_type,      through: :meeting_event
  has_one :meeting_session, through: :meeting_event
  has_one :category_type,   through: :badge
  has_one :gender_type,     through: :swimmer

  # Other available fields:
  # t.integer :suggested_minutes
  # t.integer :suggested_seconds
  # t.integer :suggested_hundreds
  # t.boolean :is_doing_this

  # Low-level instance aliases to column dynamic fields to make TimingGettable work anyway:
  def minutes;  suggested_minutes; end
  def seconds;  suggested_seconds; end
  def hundreds; suggested_hundreds; end

  include TimingGettable
  include TimingValidatable


  # Returns true if the current instance has not been currently "registered" by
  # a Swimmer.
  #
  # When a Swimmer "registers" for an event, at least one of the suggested timing
  # fields should be set to a non-nil value (or the dedicated flag #is_doing_this
  # is properly set to +true+ -- but this may not always be the case due to the
  # current data-flow when entering data).
  #
  # Note also that a timing having all zero values is used as a typical "no-time"
  # registration.
  #
  def is_not_registered
    (!is_doing_this) &&
    suggested_minutes.nil? && suggested_seconds.nil? && suggested_hundreds.nil?
  end
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
