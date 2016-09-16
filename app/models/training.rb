# encoding: utf-8


=begin

= Training model

  - version:  4.00.523
  - author:   Steve A., Leega

=end
class Training < ApplicationRecord
  after_create    UserContentLogger.new('trainings')
  after_update    UserContentLogger.new('trainings')
  before_destroy  UserContentLogger.new('trainings')

  belongs_to :user
  # [Steve, 20120212] Validating on User fails always because of validation requirements inside User (password & salt)
#  validates_associated :user                       # (Do not enable this for User)

  has_many :training_rows, dependent: :delete_all
  accepts_nested_attributes_for :training_rows, :allow_destroy => true

  has_many :exercises, through: :training_rows
  has_many :training_step_types, through: :training_rows


  validates_presence_of :title
  validates_length_of   :title, within: 1..100, allow_nil: false

  validates_presence_of :description

  validates_presence_of     :min_swimmer_level
  validates_length_of       :min_swimmer_level, within: 1..3
  validates_numericality_of :min_swimmer_level

  validates_presence_of     :max_swimmer_level
  validates_length_of       :max_swimmer_level, within: 1..3
  validates_numericality_of :max_swimmer_level


  delegate :name, to: :user, prefix: true

# FIXME for Rails 4+, move required/permitted check to the controller using the model
#  attr_accessible :title, :description, :min_swimmer_level, :max_swimmer_level,
#                  :user_id, :training_rows_attributes # (Needed by the nested_form gem)
  #-- -------------------------------------------------------------------------
  #++


  # Computes a shorter description for the name associated with this data
  def get_full_name
    title
  end

  # Computes a verbose or formal description for the name associated with this data
  def get_verbose_name
    title
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

  # Computes the total distance in meters for this training.
  #
  def compute_total_distance
    group_list = build_group_list_hash()
    group_distance = 0
    group_list.each{ |group_id, group_hash|         # Sum the total distance for each group, scanning all datarows:
      group_distance += group_hash[ :datarows ].inject(0){ |sum, row|
        sum + ( row.full_row_distance.to_i * row.times )
      } * group_hash[:times]
    }
                                                    # Start the sum of the rest of the rows using the previous result:
    self.training_rows.without_groups.inject( group_distance ){ |sum, row|
      sum + ( row.full_row_distance.to_i * row.times )
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
    group_list.each{ |group_id, group_hash|         # Sum the total secs for each group:
      group_secs += group_hash[ :datarows ].inject(0){ |sum, row|
        sum + row.full_row_seconds
      } * group_hash[:times]
    }
                                                    # Start the sum of the rest of the rows using the previous result:
    self.training_rows.without_groups.inject( group_secs ){ |sum, row|
      sum + row.full_row_seconds
    }
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
