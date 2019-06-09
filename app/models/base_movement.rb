# frozen_string_literal: true

require 'localizable'

class BaseMovement < ApplicationRecord

  include Localizable

  belongs_to :user # [Steve, 20120212] Do not validate associated user!
  belongs_to :movement_type
  belongs_to :stroke_type
  belongs_to :movement_scope_type

  validates_associated :movement_type
  # [Steve, 20140108] Update: some movements may not be linked to a stroke_type at all
  #  validates_associated :stroke_type
  validates_associated :movement_scope_type

  validates :code, presence: { length: { within: 1..6 }, allow_nil: false }
  validates :code, uniqueness: { message: :already_exists }

  delegate :code, to: :movement_type, prefix: true

  # ---------------------------------------------------------------------------
  # Base methods / overrides:
  # ---------------------------------------------------------------------------

  # Computes a run-time description for the name associated with this data
  #
  # Please note that due to the current [20140108] DB structure, this method doesn't take
  # into account that there are several base movements that may have different codes but
  # may actually refer to different exercise components having the same movements parts.
  #
  # For example, a free-style full-swimming exercise using breath count may have just the
  # same components (thus issuing the same description with this run-time method), but
  # requiring a different description for the breath count used (3, 4, 5, ...).
  #
  # For this reason, the standard, localized <tt>#i18n_short</tt> and <tt>#i18n_description</tt>
  # are the preferred methods of obtaining unique descriptions for any data row.
  #
  # === Params:
  # - verbose_level: either :short, :full or :verbose; default: :full
  # - swimmer_level_type_id: the id of the user's swimmer level type (or its preferred swimmer level type ID); NOT the code, NOT the level: the *ID*; it can be 0 if it must be ignored
  #
  def get_full_name(verbose_level = :full, _swimmer_level_type_id = 0)
    case verbose_level.to_sym
    when :short
      [
        get_stroke_type_name(verbose_level),
        get_movement_type_name(verbose_level),
        get_movement_scope_type_name(verbose_level)
      ].delete_if(&:empty?).join(' ')
    when :verbose
      [
        get_stroke_type_name(verbose_level),
        get_movement_type_name(verbose_level),
        get_movement_scope_type_name(verbose_level)
      ].delete_if(&:empty?).join(' ')
    else
      [
        get_stroke_type_name(verbose_level),
        get_movement_type_name(verbose_level),
        get_movement_scope_type_name(verbose_level)
      ].delete_if(&:empty?).join(' ')
    end
  end
  # ---------------------------------------------------------------------------

  # Retrieves the Movement Type name
  #
  # === Params:
  # - verbose_level: either :short or anything else; default: :short
  #
  def get_movement_type_name(verbose_level = :short)
    if movement_type && movement_type.code == MovementType::CODE_FULL
      ''
    elsif movement_type # Retrieve the movement_scope_type only if it is defined and it's not "full"
      if verbose_level.to_sym == :short
        movement_type.i18n_short
      else
        movement_type.i18n_description
      end
    else
      ''
    end
  end

  # Retrieves the Stroke Type name
  #
  # === Params:
  # - verbose_level: either :short or anything else; default: :short
  #
  def get_stroke_type_name(verbose_level = :short)
    return '' unless stroke_type

    if verbose_level.to_sym == :short
      stroke_type.i18n_short
    else
      stroke_type.i18n_description
    end
  end

  # Retrieves the Movement Scope Type name
  #
  # === Params:
  # - verbose_level: either :short or anything else; default: :short
  #
  def get_movement_scope_type_name(verbose_level = :short)
    if movement_scope_type && movement_scope_type.code == MovementScopeType::CODE_GENERIC
      ''
    elsif movement_scope_type # Retrieve the movement_scope_type only if it is defined and it's not "generic"
      if verbose_level.to_sym == :short
        movement_scope_type.i18n_short
      else
        movement_scope_type.i18n_description
      end
    else
      ''
    end
  end
  # ----------------------------------------------------------------------------

end
