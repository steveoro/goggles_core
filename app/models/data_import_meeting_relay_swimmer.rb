require 'wrappers/timing'
#require 'swimmer_relatable'
require 'timing_gettable'
#require 'timing_validatable'
#require 'data_importable'


#
# == DataImportMeetingRelaySwimmer
#
# Model class
#
# @author   Steve A.
# @version  4.00.811
#
class DataImportMeetingRelaySwimmer < ApplicationRecord
  include SwimmerRelatable
  include TimingGettable
  include TimingValidatable
  include DataImportable

  belongs_to :user                                  # [Steve, 20120212] Do not validate associated user!
  belongs_to :meeting_relay_swimmer, foreign_key: "conflicting_id"

  validates_presence_of :import_text

  belongs_to :data_import_meeting_relay_result
  belongs_to :data_import_swimmer
  belongs_to :data_import_badge
  belongs_to :data_import_team

  belongs_to :meeting_relay_result
  belongs_to :badge
  belongs_to :team

  belongs_to :stroke_type

  validates_associated :meeting_relay_result
  validates_associated :badge
  validates_associated :stroke_type

  validates_presence_of     :relay_order
  validates_length_of       :relay_order, within: 1..3, allow_nil: false
  validates_numericality_of :relay_order

#  attr_accessible :data_import_session_id, :import_text, :conflicting_id,
#                  :user, :user_id,
#                  :reaction_time, :minutes, :seconds, :hundreds, :relay_order,
#                  :data_import_swimmer_id, :data_import_team_id, :data_import_badge_id,
#                  :swimmer_id, :team_id, :badge_id,
#                  :stroke_type_id, :meeting_relay_result_id, :data_import_meeting_relay_result_id
  #-- --------------------------------------------------------------------------
end
