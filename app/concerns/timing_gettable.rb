# frozen_string_literal: true

require 'active_support'
require 'wrappers/timing'

#
# = TimingGettable
#
# - version:  4.00.275.20140511
#   - author:   Steve A.
#
#   Container module for interfacing common "timing-related" fields
#   and method functions.
#
module TimingGettable
  extend ActiveSupport::Concern

  # This will raise an exception if the includee does not already have defined the required fields:
  def self.included(model)
    base_instance = model.new
    unless base_instance.respond_to?(:hundreds) &&
           base_instance.respond_to?(:seconds) &&
           base_instance.respond_to?(:minutes)
      raise ArgumentError, "Includee #{model} must have the attributes #hundreds, #seconds & #minutes."
    end
  end

  # Returns a new Timing class instance initialized with the timing data from this row
  #
  def get_timing_instance
    Timing.new(hundreds.to_i, seconds.to_i, minutes.to_i)
  end

  # Returns the formatted timing information in String format.
  #
  def get_timing(show_minutes_even_if_zero = false)
    (show_minutes_even_if_zero || minutes.to_i > 0 ? "#{minutes.to_i}'" : '') +
      format('%02.0f"', seconds.to_i) +
      format('%02.0f', hundreds.to_i)
  end

  # Returns the formatted timing information in flat format.
  # This is the format used in CSI entry files
  #
  def get_timing_flattened(show_minutes_even_if_zero = false)
    (show_minutes_even_if_zero || minutes.to_i > 0 ? minutes.to_i.to_s : '') +
      format('%02.0f', seconds.to_i) +
      format('%02.0f', hundreds.to_i)
  end

  # Returns the formatted timing information in custom format.
  #
  def get_timing_custom(show_minutes_even_if_zero = false, min_separator = '', sec_separator = '')
    (show_minutes_even_if_zero || minutes.to_i > 0 ? "#{minutes.to_i}#{min_separator}" : '') +
      format('%02.0f', seconds.to_i) + sec_separator +
      format('%02.0f', hundreds.to_i)
  end
  #-----------------------------------------------------------------------------
end
