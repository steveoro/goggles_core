# encoding: utf-8

=begin

= EnhanceIndividualRankingDAO

  - Goggles framework vers.:  4.00.857
  - author: Leega

 DAO class containing the structure for enhance individual ranking rendering.
 Enhance individual ranking (EIR) is a method adopted by csi 2015-2016 season
 in which individual scores are calculated considering placement,
 performance value, personal enhancement and special bonuses.
 performance value are calculated in relation of best season type results
 Personal enhancement are referred to past seasons personal bests.
 Special bonuses are obtained with multiple medals placement in the same meeting
 or partecipation at particularly "hard" event types.
 For each swimmer involved in season the DAO provides a collection of meeting results
 (the championship takes)

=end
class EnhanceIndividualRankingDAO

  # These must be initialized on creation:
  attr_reader :season
  #-- -------------------------------------------------------------------------
  #++

  # These can be edited later on:
  attr_accessor :season, :gender_and_categories, :meetings_with_results, :total_meetings

  # Creates a new instance.
  #
  # Needs to  be sure team_scores is an instance of TeamScoreDAO
  # to perform correcto sorting
  #
  def initialize( season )
    unless season && season.instance_of?( Season )
      raise ArgumentError.new("Enhance individual ranking needs a season")
    end
    @season                = season
    @meetings_with_results = season.meetings.has_results
    @gender_and_categories = []
    @total_meetings        = @season.meetings.count
  end
  #-- -------------------------------------------------------------------------
  #++

  # Get the total ranking for gender and category
  def get_ranking_for_gender_and_category( gender_type, category_type )
    @gender_and_categories.select{|element| element.gender_type == gender_type and element.category_type == category_type }.first
  end
  #-- -------------------------------------------------------------------------
  #++

  # Calculate the total ranking for all genders and categories
  def scan_for_gender_and_category
    GenderType.individual_only.sort_by_courtesy.each do |gender_type|
      @season.category_types.are_not_relays.sort_by_age.each do |category_type|
        set_ranking_for_gender_and_category( gender_type, category_type )
      end
    end
  end
  #-- -------------------------------------------------------------------------
  #++

  # Calculate the ranking for given gender and category
  def calculate_ranking( gender_type, category_type )
    EIRGenderCategoryRankingDAO.new( @season, gender_type, category_type, @total_meetings )
  end
  #-- -------------------------------------------------------------------------
  #++

  # Set the ranking for given gender and category
  def set_ranking_for_gender_and_category( gender_type, category_type )
    @gender_and_categories << calculate_ranking( gender_type, category_type )
  end
  #-- -------------------------------------------------------------------------
  #++

  # Set the ranking for given gender and category
  # TODO Localize and store on DB
  def get_html_ranking_description( tot_meetings = @total_meetings )
    best_meetings = tot_meetings > 3 ? tot_meetings - 1 : tot_meetings
    "La classifica finale è calcolata considerando le #{best_meetings} migliori prove su #{tot_meetings}.<br>Per ogni prova vengono totalizzati i punti in base a:<ul><li>piazzamento</li><li>valore della prestazione rapportata ai record regionali</li><li>miglioramento personale</li><li>doppio podio nella manifestazione</li><li>premio gare impegnative</li></ul>".html_safe
  end
  #-- -------------------------------------------------------------------------
  #++

end
#-- ---------------------------------------------------------------------------
#++
