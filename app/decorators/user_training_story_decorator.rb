# encoding: utf-8
require 'draper'


=begin

= UserTrainingStoryDecorator

  - version:  4.00.321.20140618
  - author:   Steve A.

  Decorator for the UserTrainingStory model.
  Contains all presentation-logic centered methods.

=end
class UserTrainingStoryDecorator < Draper::Decorator
  delegate_all


  # Retrieves the UserTraining name
  def get_user_training_name
    user_training ? user_training.get_full_name : ''
  end

  # Invokes UserTraining#total_distance if available; defaults to 0
  def get_user_training_total_distance
    user_training ? user_training.total_distance : 0
  end

  # Invokes UserTraining#esteemed_total_seconds if available; defaults to 0
  def get_user_training_esteemed_total_seconds
    user_training ? user_training.esteemed_total_seconds : 0
  end
  #-- -------------------------------------------------------------------------
  #++

  # Retrieves the swimmer level typ description, when set.
  # Allows to specify which label method can be used for the output, defaults to
  # the framework standard :i18n_short.
  # Returns an empty string when not available.
  def get_swimmer_level_type( label_method_sym = :i18n_short )
    if swimmer_level_type
      swimmer_level_type.send( label_method_sym.to_sym )  # (just to be sure)
    else
      ''
    end
  end

  # Retrieves the Swimmer level type description for the associated user
  # Allows to specify which label method can be used for the output, defaults to
  # the framework standard :i18n_short.
  # Returns an empty string when not available.
  #
  def get_user_swimmer_level_type( label_method_sym = :i18n_short )
    user ? user.get_swimmer_level_type( label_method_sym ) : ''
  end
  #-- -------------------------------------------------------------------------
  #++
end
