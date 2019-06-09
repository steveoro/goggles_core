# frozen_string_literal: true

require 'wrappers/timing'
# require 'swimmer_relatable'
require 'timing_gettable'
# require 'timing_validatable'
# require 'data_importable'

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

  belongs_to :user # [Steve, 20120212] Do not validate associated user!
  belongs_to :meeting_entry, foreign_key: 'conflicting_id'

  validates :import_text, presence: true

  belongs_to :data_import_meeting_program, optional: true
  belongs_to :data_import_meeting_individual_result, optional: true
  belongs_to :data_import_meeting_entry, optional: true
  belongs_to :data_import_swimmer, optional: true
  belongs_to :data_import_team, optional: true

  belongs_to :meeting_program, optional: true
  belongs_to :meeting_individual_result, optional: true
  belongs_to :meeting_entry, optional: true
  belongs_to :team, optional: true

  belongs_to :passage_type, optional: true
  #-- --------------------------------------------------------------------------

end
