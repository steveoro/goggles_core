# frozen_string_literal: true

#
# == TimingCourseConverter
#
# Strategy Pattern implementation for long course results
# conversion to short course and viceversa
#
# @author   Leega
# @version  4.00.777
#
class TimingCourseConverter

  # Initialization within a season
  #
  # == Params:
  # An instance of season
  #
  def initialize(season)
    @season = season
  end
  #-- --------------------------------------------------------------------------
  #++

  # Get the conversion table for the season
  #
  def get_conversion_table
    @conversion_table ||= retrieve_conversion_table
  end

  # Get the conversion value for gender and event
  #
  # == Params:
  # gender_type: gender type of time swam
  # event_type:  evet type of time swam
  #
  def get_conversion_value(gender_type, event_type)
    value = get_conversion_table["#{gender_type.code}#{event_type.code}"]
    value || 0
  end

  # Convert a long course time swam in a short course time swam
  # subtracting conversion value from time swam
  #
  # == Params:
  # time_swam:   timing instance of time swam
  # gender_type: gender type of time swam
  # event_type:  evet type of time swam
  #
  def convert_time_to_short(time_swam, gender_type, event_type)
    convert_value = get_conversion_value(gender_type, event_type)
    Timing.new(time_swam.to_hundreds - convert_value)
  end

  # Convert a short course time swam in a long course time swam
  # adding conversion value to time swam
  #
  # == Params:
  # time_swam:   timing instance of time swam
  # gender_type: gender type of time swam
  # event_type:  evet type of time swam
  #
  def convert_time_to_long(time_swam, gender_type, event_type)
    convert_value = get_conversion_value(gender_type, event_type)
    Timing.new(time_swam.to_hundreds + convert_value)
  end

  # Check if conversion neede/possible
  #
  # == Params:
  # gender_type: gender type of time swam
  # event_type:  evet type of time swam
  #
  def is_conversion_possible?(gender_type, event_type)
    get_conversion_value(gender_type, event_type) > 0
  end
  #-- --------------------------------------------------------------------------
  #++

  private

  # Retrieves the conversion table for the saeson
  #
  # == Params:
  # season_id: id of the interested season
  #
  def retrieve_conversion_table
    # TODO: Store conversion table on DB and read by season
    {
      'M50SL' => 80, 'F50SL' => 70,
      'M100SL' => 175,  'F100SL'  => 150,
      'M200SL' => 375,  'F200SL'  => 330,
      'M400SL' => 850,  'F400SL'  => 720,
      'M800SL' => 1835, 'F800SL'  => 1480,
      'M1500SL' => 3700, 'F1500SL' => 2850,
      'M50DO' => 145, 'F50DO' => 125,
      'M100DO' => 300,  'F100DO'  => 260,
      'M200DO' => 640,  'F200DO'  => 560,
      'M50RA' => 85, 'F50RA' => 70,
      'M100RA' => 260,  'F100RA'  => 220,
      'M200RA' => 590,  'F200RA'  => 490,
      'M50FA' => 50, 'F50FA' => 45,
      'M100FA' => 140,  'F100FA'  => 135,
      'M200FA' => 375,  'F200FA'  => 330,
      'M200MI' => 500,  'F200MI'  => 450,
      'M400MI' => 1160, 'F400MI'  => 980
    }
  end
  #-- --------------------------------------------------------------------------
  #++

end
