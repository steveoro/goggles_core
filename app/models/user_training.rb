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
    group_list = TrainingDecorator.decorate( self ).build_group_list_hash()
    group_distance = 0
# FIXME USE NEW MOIZABLE FIELDS W/ IMPLEMENTED:
    group_list.each{ |group_id, group_hash|         # Sum the total distance for each group, scanning all datarows:
      group_distance += group_hash[ :datarows ].inject(0){ |sum, row|
        sum + ( row.compute_distance().to_i * row.times )
      } * group_hash[:times]
    }
# FIXME USE NEW MOIZABLE FIELDS W/ IMPLEMENTED:
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
    group_list = TrainingDecorator.decorate( self ).build_group_list_hash()
    group_secs = 0
# FIXME USE NEW MOIZABLE FIELDS W/ IMPLEMENTED:
    group_list.each{ |group_id, group_hash|         # Sum the total secs for each group:
      group_secs += group_hash[ :datarows ].inject(0){ |sum, row|
        sum + row.compute_total_seconds()
      } * group_hash[:times]
    }
# FIXME USE NEW MOIZABLE FIELDS W/ IMPLEMENTED:
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
    group_list = TrainingDecorator.decorate( self ).build_group_list_hash()
# FIXME USE NEW MOIZABLE FIELDS W/ IMPLEMENTED:
    group_list.each{ |group_id, group_hash|         # Sum the total secs for each group:
      if group_hash[:training_step_code] == training_step_code  
        group_secs += group_hash[ :datarows ].
          inject(0){ |sum, row| sum + row.compute_total_seconds() } * group_hash[:times]
      end 
    }
# FIXME USE NEW MOIZABLE FIELDS W/ IMPLEMENTED:

    
    # Compute not grouped rows
    self.user_training_rows.
      without_groups.
      for_training_step_code( training_step_code ).
      inject( group_secs ){ |sum, row| sum + row.compute_total_seconds() }
    
  end
  #-- -------------------------------------------------------------------------
  #++
   
end
