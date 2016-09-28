require 'drop_down_listable'


=begin

= Exercise model

  - version:  4.00.317.20140616
  - author:   Steve A., Leega

=end
class Exercise < ApplicationRecord
  include DropDownListable

  has_many :exercise_rows
  has_many :trainings,           through: :training_rows
  has_many :base_movements,      through: :exercise_rows
  has_many :training_mode_types, through: :exercise_rows

  validates_length_of     :training_step_type_codes, maximum: 50, allow_nil: true

  validates_presence_of   :code, length: { within: 1..6 }, allow_nil: false
  validates_uniqueness_of :code, message: :already_exists

  # Custom scope to detect all Exercises that may be used during a specified training_step_code
  scope :belongs_to_training_step_code, ->(training_step_code) {
    all.find_all{ |row|
      ( training_step_code.nil? ||
        row.training_step_type_codes.nil? ||
        (training_step_code.to_s == '') ||
        ( row.training_step_type_codes.instance_of?(String) &&
          row.training_step_type_codes.split(',').include?( training_step_code.to_s.upcase )
        )
      )
    }
  }
  #-- -------------------------------------------------------------------------
  #++


  # Label symbol corresponding to either a column name or a model method to be used
  # mainly in generating DropDown option lists.
  #
  # @overload inherited from DropDownListable
  #
  def self.get_label_symbol
    :get_full_name
  end
  #-- -------------------------------------------------------------------------
  #++

  # Computes the total distance in metres for this exercise.
  # (May return 0 in most cases.)
  #
  def compute_total_distance
    if exercise_rows
      exercise_rows.sort_by_part_order.inject(0){ |sum, row|
        actual_row_distance = row.compute_displayable_distance(0).to_i
        sum + actual_row_distance
      }
    else
      0
    end
  end

  # Computes the esteemed total seconds of expected duration for this exercise
  # (May return 0 in most cases.)
  #
  def compute_total_seconds
    if exercise_rows
      exercise_rows.sort_by_part_order.inject(0){ |sum, row|
        sum + row.compute_total_seconds()
      }
    else
      0
    end
  end
  #-- -------------------------------------------------------------------------
  #++

  # returns true if any of the exercise rows has a base_movement
  # that allows this aux entity type.
  #
  def is_arm_aux_allowed
    if base_movements
      base_movements.any?{ |base_movement| base_movement.is_arm_aux_allowed }
    else
      false
    end
  end

  # returns true if any of the exercise rows has a base_movement
  # that allows this aux entity type.
  #
  def is_kick_aux_allowed
    if base_movements
      base_movements.any?{ |base_movement| base_movement.is_kick_aux_allowed }
    else
      false
    end
  end

  # returns true if any of the exercise rows has a base_movement
  # that allows this aux entity type.
  #
  def is_body_aux_allowed
    if base_movements
      base_movements.any?{ |base_movement| base_movement.is_body_aux_allowed }
    else
      false
    end
  end

  # returns true if any of the exercise rows has a base_movement
  # that allows this aux entity type.
  #
  def is_breath_aux_allowed
    if base_movements
      base_movements.any?{ |base_movement| base_movement.is_breath_aux_allowed }
    else
      false
    end
  end
  #-- -------------------------------------------------------------------------
  #++

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
      row.get_full_name( total_distance, verbose_level.to_sym, swimmer_level_type_id )
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
      natural_description = er.first.get_short_description(
        total_distance,
        :true,
        (er.first.training_mode_type_code != 'A2' && er.first.base_movement.movement_type_code != 'T'),
        :true
      )
    else
      # Check if same movement in all rows
      is_same_movement = ( base_movements.distinct.count == 1 )

      if is_same_movement
        natural_description = er.first.base_movement_i18n_short + ' '
      end

      # Check if same trainng mode in all rows
      is_same_mode = ( training_mode_types.distinct.count == 1 )

      # Check if same distance
      is_same_distance = (
        (er.select(:percentage).distinct.count == 1) &&
        (er.first.percentage > 0)
      )

      # If same movements or training mode open parenthesys
      natural_description += '(' if is_same_movement or is_same_mode

      natural_description += er.collect{ |row|
        row.get_short_description(
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
