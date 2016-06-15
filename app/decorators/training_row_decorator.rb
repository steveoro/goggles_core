# encoding: utf-8
require 'draper'


=begin

= TrainingRowDecorator

  - version:  4.00.317.20140616
  - author:   Steve A.

  Decorator usable for both TrainingRow & UserTrainingRow models.
  Contains all presentation-logic centered methods.

=end
class TrainingRowDecorator < Draper::Decorator
  delegate_all


  # Computes a compact description for this data.
  #
  # It returns (joined by spaces) almost all the columns returned by #to_array()
  # except for the total seconds esteemed duration of the row. Includes also the
  # grouping text description (for grouped rows).
  #
  def get_full_name( show_also_ordinal_part = false )
    [
      get_training_group_text(),
      get_formatted_part_order(),
      get_training_step_type_short(),
      get_formatted_distance(),
      get_row_description()
    ].delete_if{ |e| e.nil? || e.to_s.empty? }.join(' ')
  end
  #-- -------------------------------------------------------------------------
  #++

  # Similarly to get_full_name, computes the description for the name associated with
  # this row, storing each main group of data as items of a single array result.
  #
  # Please note that this method will not consider any additional multiplier given by
  # any training_group linked by this row.
  # Training groups should be checked for existance and managed elsewhere, for instance,
  # during ouput formatting or in other parent entities.
  #
  # == Returns:
  # An array having the structure:
  #    [
  #      #0: ordering (string),
  #      #1: training_step_type description,
  #      #2: esteemed tot. duration in secs (integer or string, depending on the parameter),
  #      #3: total distance with multiplier (string),
  #      #4: full exercise description
  #    ]
  #
  def to_array( format_everything_to_string = false )
    [
      get_formatted_part_order(),
      get_training_step_type_short(),
      get_formatted_total_seconds(),
      get_formatted_distance(),
      get_row_description()
    ]
  end
  #-- -------------------------------------------------------------------------
  #++

  # Getter for the formatted string of the +pause+ value
  def get_formatted_pause
    Timing.to_formatted_pause( pause )
  end

  # Getter for the formatted string of the +start_and_rest+ value
  def get_formatted_start_and_rest
    Timing.to_formatted_start_and_rest( start_and_rest )
  end

  # Getter for the formatted string of the +part_order+ value
  def get_formatted_part_order
    sprintf("%02s)", part_order)
  end

  # Returns the result of #compute_total_seconds() formatted as a string.
  def get_formatted_total_seconds
    "(#{ Timing.to_minute_string(full_row_seconds) })"
  end

  # Returns the result of #compute_distance() formatted as a string.
  def get_formatted_distance
    if times > 1                                    # Hide any 1x multiplier
      "#{ sprintf("%2s", times) }x#{ sprintf("%2s", full_row_distance) }"
    else
      "#{ full_row_distance }"
    end
  end
  #-- -------------------------------------------------------------------------
  #++


  # Computes a description for the group data fields
  #
  def get_training_group_text
    if group_id.to_i > 0
      [
        "[G.#{group_id}: #{group_times}x",
        get_formatted_group_start_and_rest(),
        get_formatted_group_pause(),
        "]"
      ].delete_if{ |e| e.nil? || e.to_s.empty? }.join(' ')
    else
      ''
    end
  end

  # Getter for the formatted string of the +group_pause+ value
  def get_formatted_group_pause
    # Note that with pause > 60", Timing conversion won't be perfomed using to_compact_s
    group_pause > 0 ? " p.#{Timing.to_compact_s(0, group_pause)}" : ''
  end

  # Getter for the formatted string of the +group_start_and_rest+ value
  def get_formatted_group_start_and_rest
    group_start_and_rest > 0 ? " S-R: #{Timing.to_s(0, group_start_and_rest)}" : ''
  end
  #-- -------------------------------------------------------------------------
  #++


  # Retrieves the Training step type short name
  def get_training_step_type_short
    training_step_type ? training_step_type.i18n_short : ''
  end

  # Retrieves the Exercise full description (with possible distance override).
  #
  # The parameter +precomputed_distance+ allows to skip #compute_distance()
  # invocation, in case the value is already available externally.
  #
  def get_exercise_full( precomputed_distance = 0 )
    precomputed_distance = full_row_distance if ( precomputed_distance == 0)
    exercise ? ExerciseDecorator.decorate( exercise ).get_full_name( precomputed_distance ) : ''
  end

  # Retrieves the current row instance string description, including
  # the Exercise full description (see #get_exercise_full) and any
  # possible (& formatted) rest-pause value in seconds.
  #
  # The parameter +precomputed_distance+ allows to skip #compute_distance()
  # invocation, in case the value is already available externally.
  #
  def get_row_description( precomputed_distance = 0 )
    precomputed_distance = full_row_distance if ( precomputed_distance == 0)
    [
      get_exercise_full( precomputed_distance ),
      get_arm_aux_type_name( :short ),
      get_kick_aux_type_name( :short ),
      get_body_aux_type_name( :short ),
      get_breath_aux_type_name( :short ),
      get_formatted_start_and_rest,
      get_formatted_pause
    ].delete_if{ |e| e.nil? || e.to_s.empty? }.join(' ')
  end
  #-- -------------------------------------------------------------------------
  #++


  #-- -------------------------------------------------------------------------
  # Aux sub-entity retrieval. Checks for base_movement compatibility requested by CRUD.
  # (Verbose level param currently unused but kept here for future implementations.)
  #-- -------------------------------------------------------------------------
  #++

  # Retrieves the Arm Aux Type name
  #
  # === Params:
  # - verbose_level: either :short, :full or :verbose; default: :short
  #
  def get_arm_aux_type_name( verbose_level = :short )
    return '' unless arm_aux_type
    if verbose_level.to_sym == :short
      arm_aux_type.i18n_short
    else
      arm_aux_type.i18n_description
    end
  end

  # Retrieves the Kick Aux Type name
  #
  # === Params:
  # - verbose_level: either :short, :full or :verbose; default: :short
  #
  def get_kick_aux_type_name( verbose_level = :short )
    return '' unless kick_aux_type
    if verbose_level.to_sym == :short
      kick_aux_type.i18n_short
    else
      kick_aux_type.i18n_description
    end
  end

  # Retrieves the Body Aux Type name
  #
  # === Params:
  # - verbose_level: either :short, :full or :verbose; default: :short
  #
  def get_body_aux_type_name( verbose_level = :short )
    return '' unless body_aux_type
    if verbose_level.to_sym == :short
      body_aux_type.i18n_short
    else
      body_aux_type.i18n_description
    end
  end

  # Retrieves the Breath Aux Type name
  #
  # === Params:
  # - verbose_level: either :short, :full or :verbose; default: :short
  #
  def get_breath_aux_type_name( verbose_level = :short )
    return '' unless breath_aux_type
    if verbose_level.to_sym == :short
      breath_aux_type.i18n_short
    else
      breath_aux_type.i18n_description
    end
  end
  #-- -------------------------------------------------------------------------
  #++
end
