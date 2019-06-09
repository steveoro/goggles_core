# frozen_string_literal: true

#
# = BestLimitedRankingDAO
#
#   - Goggles framework vers.:  4.00.546
#   - author: Leega
#
#  DAO class containing the structure for best limited ranking rendering.
#  A best limited ranking is a special ranking that consider only a certain
#  number of best results
#  The DAO contains data and some utils
#
#  Attributes
#    results => meeting_individual_results considered in ranking
#    number  => number of element of results
#    score   => total score
#    average => average score of each element of results
#    min     => minimum score of results elements
#    max     => maximum score of results elements
#
class BestLimitedRankingDAO

  # These must be initialized on creation:
  attr_reader :column

  # These can be edited later on:
  attr_accessor :results, :number, :score, :average, :min, :max
  #-- -------------------------------------------------------------------------
  #++

  # Creates a new instance.
  # Should use given column
  # Automatically sets given mirs as considered results
  #
  def initialize(mirs = nil, column = :standard_points)
    @results = []
    @number  = 0
    @score   = 0
    @average = 0
    @min     = 0
    @max     = 0

    @column  = column

    set_results(mirs) if mirs
  end
  #-- -------------------------------------------------------------------------
  #++

  # Retrieve the results number
  def get_results_number
    @number ||= calculate_results_number
  end

  # Retrieve the total score
  def get_score
    @score ||= calculate_score
  end

  # Retrieve the average score
  def get_average
    @average ||= calculate_average
  end

  # Retrieve the minimum score
  def get_min
    @min ||= calculate_min
  end

  # Retrieve the maximum score
  def get_max
    @max ||= calculate_max
  end
  #-- -------------------------------------------------------------------------
  #++

  # Performs all the operation needed to reset DAO data
  def reset
    @results = []
    @number  = 0
    @score   = 0
    @average = 0
    @min     = 0
    @max     = 0
  end
  #-- -------------------------------------------------------------------------
  #++

  # Add a meeting individual result to the results collection
  def set_results(meeting_individual_results)
    @results = []
    meeting_individual_results.each do |meeting_individual_result|
      @results << meeting_individual_result
    end
    sort_results
    synchronize
  end

  # Add a meeting individual result to the results collection
  def add_result(meeting_individual_result)
    @results << meeting_individual_result
    sort_results
    synchronize
  end
  #-- -------------------------------------------------------------------------
  #++

  private

  def sort_results
    @results.sort! { |p, n| n.send(@column.to_sym) <=> p.send(@column.to_sym) }
  end

  # Performs all the operation needed to synchronize DAO data
  def synchronize
    @number  = calculate_results_number
    @score   = calculate_score
    @average = calculate_average
    @min     = calculate_min
    @max     = calculate_max
  end

  # Calculate results number
  def calculate_results_number
    @results.count
  end

  # Calculate total score considering the given column
  def calculate_score
    @results.collect { |mir| mir.send(@column.to_sym) }.sum
  end

  # Calculate average score
  def calculate_average
    @number > 0 ? @score / @number : 0
  end

  # Calculate minimum score
  def calculate_min
    if @number > 0
      results.last.send(@column.to_sym)
    else
      0
    end
  end

  # Calculate maximum score
  def calculate_max
    if @number > 0
      results.first.send(@column.to_sym)
    else
      0
    end
  end

end
