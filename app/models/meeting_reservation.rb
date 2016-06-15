# encoding: utf-8
require 'wrappers/timing'
require 'timing_gettable'


=begin

= MeetingReservation model

  - version:  4.00.835
  - author:   Steve A.

=end
class MeetingReservation < ActiveRecord::Base
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

  attr_accessible :suggested_minutes, :suggested_seconds, :suggested_hundreds

  # Low-level instance aliases to column dynamic fields to make TimingGettable work anyway:
  def minutes;  suggested_minutes; end
  def seconds;  suggested_seconds; end
  def hundreds; suggested_hundreds; end

  include TimingGettable
  include TimingValidatable
end
