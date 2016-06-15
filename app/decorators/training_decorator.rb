# encoding: utf-8
require 'draper'


=begin

= TrainingDecorator

  - version:  4.00.317.20140616
  - author:   Steve A.

  Decorator usable for both Training & UserTraining models.
  Contains all presentation-logic centered methods.

=end
class TrainingDecorator < Draper::Decorator
  delegate_all


  # Creates the Hash of all the pre-computed attributes used by type-ahead look-up
  # combos and lists.
  #
  # == Returns:
  # An Hash instance having the following structure:
  # <tt>{
  #       :label                  => #get_full_name,
  #       :value                  => id,
  #       :tot_distance           => #compute_total_distance(),
  #       :tot_secs               => #compute_total_seconds(),
  #       :user_name              => user associated with the decorated Training or UserTraining,
  #       :swimmer_level_type_description => #get_swimmer_level_type( :i18n_description ),
  #       :swimmer_level_type_alternate   => #get_swimmer_level_type( :i18n_alternate ),
  #     }</tt>.
  #
  def drop_down_attrs()
    {
      label:                          get_full_name(),
      value:                          id,
      tot_distance:                   total_distance,
      tot_secs:                       esteemed_total_seconds,
      user_name:                      get_user_name(),
      swimmer_level_type_description: get_swimmer_level_type( :i18n_description ),
      swimmer_level_type_alternate:   get_swimmer_level_type( :i18n_alternate )
    }
  end
  #-- -------------------------------------------------------------------------
  #++

  # Retrieves the Swimmer level type description from the associated user.
  # Allows to specify which label method can be used for the output, defaults to
  # the framework standard :i18n_short.
  # Returns an empty string when not available or when not associated to a user.
  #
  def get_swimmer_level_type( label_method_sym = :i18n_short )
    user ? user.get_swimmer_level_type( label_method_sym ) : ''
  end


  # Returns a text description of the required/preferred swimmer level
  # type for this training using a specified display method to be invoked
  # upon the swimmer level range found.
  #
  def get_suggested_swimmer_level_type( label_method_sym = :i18n_short )
    if self.class.respond_to?(:min_swimmer_level)
      min_level = min_swimmer_level > 0 ? SwimmerLevelType.find_by_level( min_swimmer_level ) : nil
    else
      min_level = nil
    end
    if self.class.respond_to?(:max_swimmer_level)
      max_level = max_swimmer_level > 0 ? SwimmerLevelType.find_by_level( max_swimmer_level ) : nil
    else
      max_level = nil
    end
    if min_level && max_level
      "#{ min_level.send(label_method_sym) } .. #{ max_level.send(label_method_sym) }"
    elsif min_level && max_level.nil?
      ">= #{ min_level.send(label_method_sym) }"
    elsif min_level.nil? && max_level
      "<= #{ max_level.send(label_method_sym) }"
    else
      "?"
    end
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
    if self.object.respond_to?( :training_rows )
      row_with_groups = object.training_rows.with_groups
    elsif self.object.respond_to?( :user_training_rows )
      row_with_groups = object.user_training_rows.with_groups
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
