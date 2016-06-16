# encoding: utf-8
require 'wrappers/timing'   # [Steve 20140311] Used by UserTrainingRow


=begin

= Training

  - version:  4.00.523
  - author:   Steve A., Leega

=end
class UserTraining < ActiveRecord::Base
  after_create    UserContentLogger.new('user_trainings')
  after_update    UserContentLogger.new('user_trainings')
  before_destroy  UserContentLogger.new('user_trainings')

  include TrainingSharable                          # (This adds also a belongs_to :user clause)

  has_many :user_training_rows, dependent: :delete_all
  accepts_nested_attributes_for :user_training_rows, :allow_destroy => true

  has_many :user_training_stories, dependent: :delete_all

  has_many :exercises,           through: :user_training_rows
  has_many :training_step_types, through: :user_training_rows

  validates_presence_of :description
  validates_length_of   :description, within: 1..250, allow_nil: false


  delegate :name, to: :user,               prefix: true

  attr_accessible :description,
                  :user_id, :user_training_rows_attributes, # (Needed by the nested_form gem)
                  :user_training_story_attributes

  scope :sort_by_description,     order('description')
  #-- -------------------------------------------------------------------------
  #++


  # Computes a shorter description for the name associated with this data
  def get_full_name
    description
  end

  # Computes a verbose or formal description for the name associated with this data
  def get_verbose_name
    # Verbose description should show first user_training_story date and pool
    description
  end

  # Retrieves the User short name (the owner of this Training)
  # @ deprecated
  def get_user_name
    user ? user.name : ''
  end
  #-- -------------------------------------------------------------------------
  #++


  # Memoized (lazy-loaded & cached) value of #compute_total_distance()
  def total_distance
    @total_distance ||= compute_total_distance()
  end

  # Computes the total distance in metres for this training.
  #
  def compute_total_distance
    group_list = build_group_list_hash()
    group_distance = 0
# FIXME USE NEW MEMOIZABLE FIELDS:
    group_list.each{ |group_id, group_hash|         # Sum the total distance for each group, scanning all datarows:
      group_distance += group_hash[ :datarows ].inject(0){ |sum, row|
        sum + ( row.compute_distance().to_i * row.times )
      } * group_hash[:times]
    }
# FIXME USE NEW MEMOIZABLE FIELDS:
                                                    # Start the sum of the rest of the rows using the previous result:
    self.user_training_rows.without_groups.inject( group_distance ){ |sum, row|
      sum + ( row.compute_distance().to_i * row.times )
    }
  end
  #-- -------------------------------------------------------------------------
  #++


  # Memoized (lazy-loaded & cached) value of #compute_total_seconds()
  def esteemed_total_seconds
    @esteemed_total_seconds ||= compute_total_seconds()
  end

  # Computes the esteemed total seconds of expected duration for this training
  #
  def compute_total_seconds
    group_list = build_group_list_hash()
    group_secs = 0
# FIXME USE NEW MEMOIZABLE FIELDS:
    group_list.each{ |group_id, group_hash|         # Sum the total secs for each group:
      group_secs += group_hash[ :datarows ].inject(0){ |sum, row|
        sum + row.compute_total_seconds()
      } * group_hash[:times]
    }
# FIXME USE NEW MEMOIZABLE FIELDS:
                                                    # Start the sum of the rest of the rows using the previous result:
    self.user_training_rows.without_groups.inject( group_secs ){ |sum, row|
      sum + row.compute_total_seconds()
    }
  end
  #-- -------------------------------------------------------------------------
  #++


  # Computes the total distance for a given training step
  #
  # params
  # training_step_code: traing step to cpmpute distance for
  #
  def compute_step_distance( training_step_code )
    group_secs = 0

    # Compute grouped rows
    group_list = build_group_list_hash()
# FIXME USE NEW MEMOIZABLE FIELDS:
    group_list.each{ |group_id, group_hash|         # Sum the total secs for each group:
      if group_hash[:training_step_code] == training_step_code
        group_secs += group_hash[ :datarows ].
          inject(0){ |sum, row| sum + row.compute_total_seconds() } * group_hash[:times]
      end
    }
# FIXME USE NEW MEMOIZABLE FIELDS:

    # Compute not grouped rows
    self.user_training_rows.
      without_groups.
      for_training_step_code( training_step_code ).
      inject( group_secs ){ |sum, row| sum + row.compute_total_seconds() }

  end
  #-- -------------------------------------------------------------------------
  #++


  # Builds up an Hash of "decorated" detail fields, grouping them together (if they are grouped).
  #
  # Scans all the training rows with groups and builds up a custom hash containing
  # as keys the group_id and as value another hash having all group fields as data members,
  # plus a special :datarows array member, containing all the data rows linked to the same
  # group id.
  #
  # Only the first row found with a valid group id (>0) will be used for group definition;
  # the others will only be checked for group_id consistency.
  #
  # It returns an empty Hash if the current Training instance has no groups defined.
  #
  def build_group_list_hash
    # Create objects either from training and user_trainings
    if self.respond_to?( :training_rows )
      row_with_groups = self.training_rows.with_groups
    elsif self.respond_to?( :user_training_rows )
      row_with_groups = self.user_training_rows.with_groups
    else
      row_with_groups = []
    end

    group_list = {}                                 # Collect a custom hash and a list of data rows for each group of rows:
    row_with_groups.each{ |row|                     # If the group id is missing from the hash keys, add it:
      unless group_list.has_key?( row.group_id )
        group_list[ row.group_id ] = {
          id:                 row.group_id,
          times:              row.group_times,
          start_and_rest:     row.group_start_and_rest,
          pause:              row.group_pause,
          training_step_code: row.training_step_type_code,
          datarows:       [ row ]
        }
      else                                          # Else, if the group id is among the keys, simply add the datarow to the list:
        group_list[ row.group_id ][ :datarows ] << row
      end
    }

    # Compute totals
    group_list.each do |key, element|
      tot_group_secs   = TrainingRow.compute_total_seconds( element[:datarows] )
      tot_group_timing = Timing.to_minute_string( tot_group_secs )
      element[:tot_group_timing] = tot_group_timing
    end

    group_list
  end
  #-- -------------------------------------------------------------------------
  #++
end
