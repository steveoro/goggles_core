# encoding: utf-8
require 'wrappers/timing'

=begin

= TimingParser

 - Goggles framework vers.:  4.00.851
 - author: Steve A.

 Simple parser strategy class, that tries to parse any supplied string for a
 timing-like format, returning either a Timing instance on successful parsing
 or nil in case of parsing errors.

=end
class TimingParser

  # Parses the specified text for a possible timing value, returning either a
  # Timing instance or nil, in case of parsing errors.
  #
  # == Recognized formats:
  # 1) dd'dd"dd
  # 2) dd:dd[:.]dd
  # 3) dd.dd.dd
  #
  def self.parse( timing_text )
    case timing_text
    when /(\d*\'?\d{0,2}\"\d{1,2}|\d*\'\d{1,2}\"?\d{0,2})/
      minutes  = timing_text =~ /'/ ? timing_text.split("'").first.to_i : 0
      seconds  = timing_text =~ /['"]/ ? timing_text.split("'").last.split("\"").first.to_i : 0
      hundreds = timing_text =~ /"/ ? timing_text.split("'").last.split("\"").last.to_i : 0
      Timing.new( hundreds, seconds, minutes )

    when /(\d*\:\d{0,2}([\.\:]\d{1,2})?)/
      minutes  = timing_text =~ /\:/ ? timing_text.split(":").first.to_i : 0
      seconds  = timing_text =~ /[\.\:]/ ? timing_text.split(":")[1].split(/[\.\:]/).first.to_i : 0
      hundreds = timing_text =~ /[\.\:]/ ? timing_text.split(":").last.split(/[\.\:]/).last.to_i : 0
      Timing.new( hundreds, seconds, minutes )

    when /(\d*\.\d{1,2}\.\d{1,2})/
      minutes  = timing_text =~ /\./ ? timing_text.split(".").first.to_i : 0
      seconds  = timing_text =~ /\./ ? timing_text.split(".")[1].to_i : 0
      hundreds = timing_text =~ /\./ ? timing_text.split(".").last.to_i : 0
      Timing.new( hundreds, seconds, minutes )

    else
      nil
    end
  end
  #-- --------------------------------------------------------------------------
  #++
end
