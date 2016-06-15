# encoding: utf-8
require 'draper'


=begin

= ExerciseDecorator

  - version:  4.00.525
  - author:   Steve A., Leega

  Decorator for the Exercise model.
  Contains all presentation-logic centered methods.

=end
class ExerciseDecorator < Draper::Decorator
  delegate_all


  # Creates the Hash of all the pre-computed attributes used by type-ahead look-up
  # combos and lists.
  #
  # == Params:
  # - <tt>current_user</tt> => the current_user instance, when available.
  #
  # == Returns:
  # An Hash instance having the following structure:
  # <tt>{
  #       :label                  => #get_full_name,
  #       :value                  => row.id,
  #       :tot_distance           => #compute_total_distance(),
  #       :tot_secs               => #compute_total_seconds(),
  #       :is_arm_aux_allowed     => #is_arm_aux_allowed(),
  #       :is_kick_aux_allowed    => #is_kick_aux_allowed(),
  #       :is_body_aux_allowed    => #is_body_aux_allowed(),
  #       :is_breath_aux_allowed  => #is_breath_aux_allowed(),
  #     }</tt>.
  #
  def drop_down_attrs( current_user = nil )
    {
      label:                  get_full_name(
                                0, :short,
                                ( current_user ? current_user.get_preferred_swimmer_level_id() : 0 )
                              ),
      value:                  id,
      tot_distance:           compute_total_distance(),
      tot_secs:               compute_total_seconds(),
      is_arm_aux_allowed:     is_arm_aux_allowed(),
      is_kick_aux_allowed:    is_kick_aux_allowed(),
      is_body_aux_allowed:    is_body_aux_allowed(),
      is_breath_aux_allowed:  is_breath_aux_allowed()
    }
  end
  #-- -------------------------------------------------------------------------
  #++


  # Computes a full description for this data row
  #
  # === Params:
  # - total_distance: can be 0 if it must be obtained from each component
  # - verbose_level: either :short, :full or :verbose; default: :full
  # - swimmer_level_type_id: the id of the user's swimmer level type (or its preferred swimmer level type ID); NOT the code, NOT the level: the *ID*; it can be 0 if it must be ignored
  # - separator: string separator for joining each field
  #
  def get_full_name( total_distance = 0, verbose_level = :full, swimmer_level_type_id = 0, separator = " + " )
    exercise_rows.sort_by_part_order.collect{ |row|
      ExerciseRowDecorator.decorate( row ).get_full_name( total_distance, verbose_level.to_sym, swimmer_level_type_id )
    }.join(separator)
  end
  #-- -------------------------------------------------------------------------
  #++


  # Returns a "natural" friendly description for exercises.
  # The "natural" description is obtanied computing
  # exercise row and combineing elements with some optimization
  # to create compact and more readable results
  #
  # If exercise rows of exercises with multiple rows has
  # the same base movement it will precede the description, never repeated
  # eg: SL (25 fast + 50 slow + 25 fast)      instead of
  #     25 SL fast + 50 SL slow + 25 SL fast
  #
  # If exercise rows of exercises with multiple rows has
  # the same training mode it will forward the description enclosed in parethesiys
  # eg: (25 SL + 25 DO) fast                  instead of
  #     25 SL fast + 25 DO fast
  #  (maybe shuld be better: SL/DO fast change at 25)
  #
  # If the training mode is A2 it sohuld be omissed (it's the default)
  # eg: 50 SL + 50 DO                         instead of
  #     50 SL resistance + 50 DO resistance
  #  or 25 FA fast + 25 SL                    instead of
  #     25 FA fast + 25 SL resistance
  #
  # If the distance is unknown and rows have same %, should compress
  # description suppressing percentage
  # eg: SL fast + DO slow                     instead of
  #     50% SL fast + 50% DO slow
  #
  # Remove slow indication on pure technique movements (movement_type_code = 'T')
  # eg: SL 1 arm ahead + SL resistance        instead of
  #     50% SL 1 arm ahead slow + 50% SL resistance
  #
  # TODO Optimize stroke type on base movement. Should refactor base_movement seed
  # to obtain something like:
  # SL (kick only + complete) resistance instead of (SL kick only + SL) resistance
  # (SL + RA) kick only resistance instead of (SL kick only + RA kick only) resistance
  #
  # So, finally we will have
  # (25 FA + 25 SL) fast                      instead of
  # 25 FA fast + 25 SL fast
  # or
  # SL (15 fast + 35 slow)                    instead of
  # 15 SL fast + 35 SL slow
  #
  def get_friendly_description( total_distance = 0, swimmer_level_type_id = 0, separator = " + " )
    natural_description = ''
    er = exercise_rows.includes([:base_movement, :training_mode_type, :movement_type]).sort_by_part_order

    # If only one row should use exercise short description
    # suppressing training mode if A2
    if er.count == 1
      natural_description = er.first.decorate.get_short_description(
        total_distance,
        :true,
        (er.first.training_mode_type_code != 'A2' && er.first.base_movement.movement_type_code != 'T'),
        :true)
    else
      # Check if same movement in all rows
      is_same_movement = ( base_movements.uniq.count == 1 )

      if is_same_movement
        natural_description = er.first.base_movement_i18n_short + ' '
      end

      # Check if same trainng mode in all rows
      is_same_mode = ( training_mode_types.uniq.count == 1 )

      # Check if same distance
      is_same_distance = ( er.select(:percentage).uniq.map{ |row| row.percentage }.count == 1 && er.first.percentage > 0 )

      # If same movements or training mode open parenthesys
      natural_description += '(' if is_same_movement or is_same_mode

      natural_description += er.collect{ |row|
        ExerciseRowDecorator.decorate( row ).get_short_description(
          total_distance,
          not(is_same_movement),
          (not(is_same_mode) && row.base_movement.movement_type_code != 'T'),
          not(is_same_distance)
        )
      }.join(separator)

      # If same movements close parenthesys
      natural_description += ')' if is_same_movement or is_same_mode

      # If same mode add mode
      natural_description += ' ' + er.first.training_mode_type_i18n_alternate if is_same_mode

      # debug. Remove this
      #natural_description += ' [' + code + ']'
    end
    natural_description
  end
  #-- -------------------------------------------------------------------------
  #++
end
