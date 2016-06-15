# encoding: utf-8
require 'wrappers/timing'
require 'draper'


=begin

= ExerciseRowDecorator

  - version:  4.00.313.20140610
  - author:   Steve A.

  Decorator for the ExerciseRow model.
  Contains all presentation-logic centered methods.

=end
class ExerciseRowDecorator < Draper::Decorator
  delegate_all


  # Returns a full description for this data row.
  #
  # === Params:
  # - total_distance: can be 0 if it must be obtained from each component
  # - verbose_level: either :short, :full or :verbose; default: :full
  # - swimmer_level_type_id: the id of the user's swimmer level type (or its preferred swimmer level type ID); NOT the code, NOT the level: the *ID*; it can be 0 if it must be ignored
  # - show_also_ordinal_part: true to show also the part_order; defaults to false.
  #
  def get_full_name( total_distance = 0, verbose_level = :full, swimmer_level_type_id = 0, show_also_ordinal_part = false )
    case verbose_level.to_sym
    when :short
      [
        ( show_also_ordinal_part ? sprintf("%02s)", part_order) : '' ),
        compute_displayable_distance( total_distance ),
        get_base_movement_short( true, swimmer_level_type_id ),
        get_training_mode_type_friendly,
        get_execution_note_type_name( verbose_level ),
        get_formatted_start_and_rest,
        get_formatted_pause
      ].delete_if{ |e| e.to_s.empty? }.join(' ')
    when :verbose
      [
        ( show_also_ordinal_part ? sprintf("%02s)", part_order) : '' ),
        compute_displayable_distance( total_distance ),
        get_base_movement_full( true, swimmer_level_type_id ),
        get_training_mode_type_name( verbose_level ),
        get_execution_note_type_name( verbose_level ),
        get_formatted_start_and_rest,
        get_formatted_pause
      ].delete_if{ |e| e.to_s.empty? }.join(' ')
    else
      [
        ( show_also_ordinal_part ? sprintf("%02s)", part_order) : '' ),
        compute_displayable_distance( total_distance ),
        get_base_movement_short( true, swimmer_level_type_id ),
        get_training_mode_type_name( :execution ),
        get_execution_note_type_name( :short ),
        get_formatted_start_and_rest,
        get_formatted_pause
      ].delete_if{ |e| e.to_s.empty? }.join(' ')
    end
  end
  #-- -------------------------------------------------------------------------
  #++

  # Returns a "natural" description for this data row.
  # The "natural" description is obtanied computing
  # exercise row and cobineing elements with some optimization
  # to create compact and more readable result
  #
  # === Params:
  # - total_distance: can be 0 if it must be obtained from each component
  # - swimmer_level_type_id: the id of the user's swimmer level type (or its preferred swimmer level type ID); NOT the code, NOT the level: the *ID*; it can be 0 if it must be ignored
  # - add_movement: should add stroke indication (base movement)
  # - add_mode: should add training mode indication
  # - add_distance: should add distance indication
  #
  def get_short_description( total_distance = 0, add_movement = :true, add_mode = :true, add_distance = :true)
    [ add_distance ? compute_displayable_distance( total_distance ) : '',
      add_movement ? base_movement_i18n_short : '',
      add_mode ? training_mode_type_i18n_alternate : '',
      get_execution_note_type_name,
      get_formatted_start_and_rest,
      get_formatted_pause
    ].delete_if{ |e| e.to_s.empty? }.join(' ')
  end
  #-- -------------------------------------------------------------------------
  #++

  # Returns the formatted string of the +pause+ value
  def get_formatted_pause
    Timing.to_formatted_pause( pause )
  end

  # Returns the formatted string of the +start_and_rest+ value
  def get_formatted_start_and_rest
    Timing.to_formatted_start_and_rest( start_and_rest )
  end
  #-- -------------------------------------------------------------------------
  #++


  # Returns the BaseMovement full description
  #
  # === Params:
  # - use_i18n_desc: true to use the localized version of the description instead of the computed one; default to false
  # - swimmer_level_type_id: the id of the user's swimmer level type (or its preferred swimmer level type ID); NOT the code, NOT the level: the *ID*; it can be 0 if it must be ignored
  #
  def get_base_movement_full( use_i18n_desc = false, swimmer_level_type_id = 0 )
    return '' unless base_movement
    if use_i18n_desc
      base_movement.i18n_description
    else
      base_movement.get_full_name( :full, swimmer_level_type_id )
    end
  end

  # Returns the BaseMovement short description
  #
  # === Params:
  # - use_i18n_desc: true to use the localized version of the description instead of the computed one; default to false
  # - swimmer_level_type_id: the id of the user's swimmer level type (or its preferred swimmer level type ID); NOT the code, NOT the level: the *ID*; it can be 0 if it must be ignored
  #
  def get_base_movement_short( use_i18n_desc = false, swimmer_level_type_id = 0 )
    return '' unless base_movement
    if use_i18n_desc
      base_movement.i18n_short
    else
      base_movement.get_full_name( :short, swimmer_level_type_id )
    end
  end

  # Returns the ExecutionNoteTypes name
  #
  # === Params:
  # - verbose_level: either :short, :full or :verbose; default: :short
  #
  def get_execution_note_type_name( verbose_level = :short )
    return '' unless execution_note_type
    if verbose_level.to_sym == :short
      execution_note_type.i18n_short
    else
      execution_note_type.i18n_description
    end
  end

  # Returns the Training Mode type name
  #
  # === Params:
  # - verbose_level: either :short, :full or :verbose; default: :short
  #
  def get_training_mode_type_name( verbose_level = :short )
    return '' unless training_mode_type
    if verbose_level.to_sym == :short
      training_mode_type.i18n_short
    else
      training_mode_type.i18n_alternate
    end
  end

  # TODO Refactor that ugly solution. Maybe redefine the seed
  # Returns the Training Mode type short name
  #
  def get_training_mode_type_friendly
    return '' unless training_mode_type
    training_mode_type.i18n_alternate
  end
  #-- -------------------------------------------------------------------------
  #++
end
