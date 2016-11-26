# encoding: utf-8
require 'wrappers/timing'


=begin

= MeetingEventReservation model

  - version:  6.018
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

  has_one  :season_type,      through: :meeting_event
  has_one  :event_type,       through: :meeting_event

# FIXME for Rails 4+, move required/permitted check to the controller using the model
#  attr_accessible :suggested_minutes, :suggested_seconds, :suggested_hundreds

  # Low-level instance aliases to column dynamic fields to make TimingGettable work anyway:
  def minutes;  suggested_minutes; end
  def seconds;  suggested_seconds; end
  def hundreds; suggested_hundreds; end

  include TimingGettable
  include TimingValidatable
end
