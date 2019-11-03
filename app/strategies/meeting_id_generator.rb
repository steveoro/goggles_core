# frozen_string_literal: true

require 'common/format'

#
# = MeetingIDGenerator
#   - Goggles framework vers.:  6.327
#   - author: Steve A.
#
#  Meeting's "talkative ID" generator.
#
#  Allows to find & generate a new "talking ID" for all meetings occurring after 2010.
#
class MeetingIDGenerator

  # Values used for the 3rd digit of the generated free ID, according to season_type.code
  THIRD_DIGIT_VALUE = {
    'MASCSI' => 1,     # DO NOT CONFUSE WITH SEASON TYPE ID! (For MASCSI season_type is '2')
    'MASFIN' => 2,     # DO NOT CONFUSE WITH SEASON TYPE ID! (For MASFIN season_type is '1')
    'MASLEN' => 3,
    'MASFINA' => 4,
    'MASUISP' => 5
  }.freeze

  # Returns a new, free ID for a new Meeting yet to be created, or nil in case of
  # errors or when no free "slot" was found.
  #
  # === Params:
  #
  # - season, the Season instance of the new Meeting.
  # - max_meeting_count, the maximum Meeting count presumed for the season (this
  #   is just an end-search bias that influences the resulting availability of
  #   the ID).
  #
  def self.get_free_id( season, max_meeting_count = 150 )
    return nil unless season.instance_of?( Season )

    first_2_digits = season.begin_date.year - 2000
    search_id_start = first_2_digits * 1000 + THIRD_DIGIT_VALUE[season.season_type.code].to_i * 100

    range = ( search_id_start..search_id_start + max_meeting_count ).to_a
    not_free = Meeting.where( ['(id >= ?) AND (id < ?)', search_id_start, search_id_start + max_meeting_count] )
                      .select(:id).order(:id)
                      .map(&:id)
    available = range - not_free
    # DEBUG
    #    puts "\r\nseason: #{ season.inspect }"
    #    puts "- range: #{ search_id_start } .. #{ search_id_start + max_meeting_count }"
    #    puts "- available size: #{ available.count }"
    #    puts "=> #{ available.inspect }"

    # Found a free meeting slot inside boundaries? Double-check if the ID is free:
    if (available.count > 0) && !Meeting.exists?( available.first )
      available.first
      # No solution found:
    end
  end
  #-- --------------------------------------------------------------------------
  #++

end
