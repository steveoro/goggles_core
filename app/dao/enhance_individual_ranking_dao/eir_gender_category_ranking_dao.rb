# frozen_string_literal: true

#
# = EnhanceIndividualRankingDAO::EIRGenderCategoryRankingDAO
#
#   - Goggles framework vers.:  4.00.857
#   - author: Leega
#
#  DAO class containing the structure for enhance individual ranking rendering.
#  Enhance individual ranking (EIR) is a method adopted by csi 2015-2016 season
#  in which individual scores are calculated considering placement,
#  performance value, personal enhancement and special bonuses.
#  performance value are calculated in relation of best season type results
#  Personal enhancement are referred to past seasons personal bests.
#  Special bonuses are obtained with multiple medals placement in the same meeting
#  or partecipation at particularly "hard" event types.
#  For each swimmer involved in season the DAO provides a collection of meeting results
#  (the championship takes)
#
class EnhanceIndividualRankingDAO

  # Each swimmer has a gender and a category
  # Each swimmer has a collection of meetings (results)
  class EIRGenderCategoryRankingDAO

    # These must be initialized on creation:
    attr_reader :gender_type, :category_type

    # These can be edited later on:
    attr_accessor :swimmers, :gender_type, :category_type
    #-- -------------------------------------------------------------------------
    #++

    # Creates a new instance
    #
    def initialize(season, gender_type, category_type, total_meetings = season.meetings.count)
      raise ArgumentError, 'Enhanced individual ranking needs a season' unless season&.instance_of?(Season)
      unless gender_type&.instance_of?(GenderType)
        raise ArgumentError, 'Enhanced individual ranking for gender and category needs a gender type'
      end
      unless category_type&.instance_of?(CategoryType)
        raise ArgumentError, 'Enhanced individual ranking for gender and category needs a category type'
      end

      @gender_type   = gender_type
      @category_type = category_type
      @swimmers      = []

      # Search swimmers for the season, gender and category
      season.badges.for_gender_type(gender_type).for_category_type(category_type).each do |badge|
        @swimmers << EIRSwimmerScoreDAO.new(badge.swimmer, season, total_meetings) if badge.meeting_individual_results.exists?
      end

      # Sort swimmers by total points
      @swimmers.sort! { |p, n| n.total_best_5_on_6 <=> p.total_best_5_on_6 }
    end
    #-- -------------------------------------------------------------------------
    #++

  end

end
#-- ---------------------------------------------------------------------------
#++
