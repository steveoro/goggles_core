# encoding: utf-8


=begin

= Training model

  - version:  4.00.523
  - author:   Steve A., Leega

=end
class Training < ActiveRecord::Base
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

  attr_accessible :title, :description, :min_swimmer_level, :max_swimmer_level,
                  :user_id, :training_rows_attributes # (Needed by the nested_form gem)
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
    group_list = TrainingDecorator.decorate( self ).build_group_list_hash()
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
    group_list = TrainingDecorator.decorate( self ).build_group_list_hash()
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
end
