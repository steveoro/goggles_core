# frozen_string_literal: true

#
# = Timing
#   - Goggles framework vers.:  4.00.783
#   - author: Steve A.
#
#  Utility class to store timing data and to allow simple mathematical operations
#  between timings (delta, sum, ...).
#
# === Members:
#  - <tt>:hundreds</tt> => Fixnum value for hundreds of a second.
#  - <tt>:seconds</tt> => Fixnum value for seconds.
#  - <tt>:minutes</tt> => Fixnum value for minutes.
#  - <tt>:hours</tt> => Fixnum value for hours.
#  - <tt>:days</tt> => Fixnum value for days.
#
class Timing

  include Comparable

  attr_accessor :hundreds, :seconds, :minutes, :hours, :days

  # Creates a new instance.
  # Note the ascending precision of the parameters, which allows to skip
  # the rarely used ones.
  #
  def initialize(hundreds = 0, seconds = 0, minutes = 0, hours = 0, days = 0)
    @hundreds = hundreds.to_i
    @seconds = seconds.to_i
    @minutes = minutes.to_i
    @hours = hours.to_i
    @days = days.to_i
    # Adjust the result:
    set_from_hundreds(to_hundreds)
  end

  # Clears the cached results. This method is useful only if the same V2::TokenExtractor
  # instance is used to tokenize different source texts.
  #
  def clear
    @hundreds = 0
    @seconds = 0
    @minutes = 0
    @hours = 0
    @days = 0
    self
  end
  #-- -------------------------------------------------------------------------
  #++

  # Sets the current instance value according to the total Fixnum value of hundreds of a second
  # specified as a parameter.
  #
  def set_from_hundreds(hundreds_value)
    @days = hundreds_value / 8_640_000
    remainder = hundreds_value % 8_640_000
    @hours = remainder / 360_000
    remainder = remainder % 360_000
    @minutes = remainder / 6000
    remainder = remainder % 6000
    @seconds = remainder / 100
    remainder = remainder % 100
    @hundreds = remainder
    self
  end
  #-- -------------------------------------------------------------------------
  #++

  # Returns a new instance containing as member values the sum of the current instance
  # with the one specified as a parameter.
  #
  def +(timing)
    Timing.new(
      @hundreds + timing.hundreds,
      @seconds + timing.seconds,
      @minutes + timing.minutes,
      @hours + timing.hours,
      @days + timing.days
    )
  end

  # Returns a new instance containing as member values the differemce between
  # the current instance and the one specified as a parameter.
  #
  def -(timing)
    Timing.new(
      @hundreds - timing.hundreds,
      @seconds - timing.seconds,
      @minutes - timing.minutes,
      @hours - timing.hours,
      @days - timing.days
    )
  end

  # Equals operator. Returns true if the two Timing objects have the same
  # value. +false+ otherwise.
  #
  def ==(timing)
    return false unless timing.instance_of?(Timing)

    (
      @days == timing.days &&
      @hours == timing.hours &&
      @minutes == timing.minutes &&
      @seconds == timing.seconds &&
      @hundreds == timing.hundreds
    )
  end

  # Comparable operator. Returns -1, 0, or 1 depending on the order between the
  # two Timing objects.
  # Returns always 1 for nil values.
  #
  # (See +Comparable+ class in Ruby library)
  #
  def <=>(timing)
    raise ArgumentError, 'the parameter (' + timing.class.name + ') is not a Timing instance or nil!' if !timing.nil? && !timing.instance_of?(Timing)

    timing.nil? ? 1 : to_hundreds <=> timing.to_hundreds
  end
  #-- -------------------------------------------------------------------------
  #++

  # Converts the current instance to total Fixnum value of hundreds of a second.
  def to_hundreds
    @hundreds + @seconds * 100 + @minutes * 6000 +
      @hours * 360_000 + @days * 8_640_000
  end

  # Converts the current instance to a readable string.
  def to_s
    (days.to_i > 0 ? "#{days}d " : '') +
      (hours.to_i > 0 ? "#{hours}h " : '') +
      format(
        minutes.to_i > 0 ? "%2s'%02.0f\"%02.0f" : "%2s'%2s\"%02.0f",
        minutes.to_i, seconds.to_i, hundreds.to_i
      )
  end
  #-- -------------------------------------------------------------------------
  #++

  # Commodity class method. Same as to_s.
  #
  def self.to_s(hundreds = 0, seconds = 0, minutes = 0, hours = 0, days = 0)
    Timing.new(hundreds, seconds, minutes, hours, days).to_s
  end

  # Commodity class method. Similar to +to_s+ method, but it doesn't include
  # members with non positive values in the output string.
  #
  def self.to_compact_s(hundreds = 0, seconds = 0, minutes = 0, hours = 0, days = 0)
    (days.to_i == 0 ? '' : "#{days}d ") +
      (hours.to_i == 0    ? '' : "#{hours}h ") +
      (minutes.to_i == 0  ? '' : format("%2s'", minutes)) +
      (seconds.to_i == 0  ? '' : format((minutes > 0 ? '%02.0f"' : '%2s"'), seconds)) +
      (hundreds.to_i == 0 ? '' : format('%02.0f', hundreds))
  end
  #-- -------------------------------------------------------------------------
  #++

  # Outputs the specified value of seconds in an hour-format string (Hh MM' SS").
  # It skips the output of any 2-digit part when its value is 0.
  # (This is true for hours, minutes, seconds and even hundreds, making this method
  # ideal to represent a total duration or span of time, without displaying the
  # non-significant members).
  #
  def self.to_hour_string(total_seconds)
    hours = total_seconds.to_i / 3600
    remainder = total_seconds.to_i % 3600
    minutes = remainder / 60
    seconds = remainder % 60
    to_compact_s(0, seconds, minutes, hours)
  end

  # Outputs the specified value of seconds in a minute-format (M'SS").
  # It skips the output of the minutes when 0.
  #
  def self.to_minute_string(total_seconds)
    minutes = total_seconds.to_i / 60
    seconds = total_seconds.to_i % 60
    to_compact_s(0, seconds, minutes)
  end
  #-- -------------------------------------------------------------------------
  #++

  # Outputs the specified value of seconds in a "pause in seconds" format (P.SS").
  # Returns an empty string if the value is 0.
  #
  def self.to_formatted_pause(total_seconds)
    # Note that with pause > 60", Timing conversion won't be perfomed using to_compact_s
    total_seconds.to_i > 0 ? " p.#{Timing.to_compact_s(0, total_seconds.to_i)}" : ''
  end

  # Outputs the specified value of seconds in a "Start-Rest " format (S-R: M'.SS").
  # Returns an empty string if the value is 0.
  #
  def self.to_formatted_start_and_rest(total_seconds)
    total_seconds.to_i > 0 ? " SR.#{Timing.to_minute_string(total_seconds.to_i)}" : ''
  end
  #-- -------------------------------------------------------------------------
  #++

end
