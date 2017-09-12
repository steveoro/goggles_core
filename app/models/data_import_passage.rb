require 'wrappers/timing'
#require 'swimmer_relatable'
require 'timing_gettable'
#require 'timing_validatable'
#require 'data_importable'


#
# == DataImportPassage
#
# Model class
#
# @author   Steve A.
# @version  4.00.811
#
class DataImportPassage < ApplicationRecord
  include SwimmerRelatable
  include TimingGettable
  include TimingValidatable
  include DataImportable

  belongs_to :user                                  # [Steve, 20120212] Do not validate associated user!
  belongs_to :meeting_entry, foreign_key: "conflicting_id"

  validates_presence_of :import_text

  belongs_to :data_import_meeting_program
  belongs_to :data_import_meeting_individual_result
  belongs_to :data_import_meeting_entry
  belongs_to :data_import_swimmer
  belongs_to :data_import_team

  belongs_to :meeting_program
  belongs_to :meeting_individual_result
  belongs_to :meeting_entry
  belongs_to :team

  belongs_to :passage_type
  #-- --------------------------------------------------------------------------
end
